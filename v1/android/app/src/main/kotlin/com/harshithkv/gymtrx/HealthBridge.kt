package com.harshithkv.gymtrx

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.activity.result.ActivityResultLauncher
import androidx.fragment.app.FragmentActivity
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.records.metadata.Metadata
import androidx.health.connect.client.request.AggregateGroupByPeriodRequest
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.units.Mass
import androidx.lifecycle.lifecycleScope
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import java.time.LocalDate
import java.time.Period
import java.time.ZoneId
import kotlin.reflect.KClass
import kotlinx.coroutines.launch

/**
 * Health Connect for GYMTRX, over the `gymtrx/health` channel. Uses the
 * official Jetpack client directly: GYMTRX needs per-day step totals, other
 * apps' workouts (never its own), and upserts keyed by its own record ids.
 *
 * Times cross the channel as epoch milliseconds, days as yyyymmdd ints.
 */
class HealthBridge(private val activity: FragmentActivity) : MethodChannel.MethodCallHandler {

    private var pendingPermissions: MethodChannel.Result? = null

    // Registered while the activity is being constructed, as Android requires.
    private val permissionLauncher: ActivityResultLauncher<Set<String>> =
        activity.registerForActivityResult(PermissionController.createRequestPermissionResultContract()) { granted ->
            pendingPermissions?.success(granted.toList())
            pendingPermissions = null
        }

    private val client: HealthConnectClient by lazy { HealthConnectClient.getOrCreate(activity) }

    private val zone: ZoneId get() = ZoneId.systemDefault()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> result.success(
                when (HealthConnectClient.getSdkStatus(activity, PROVIDER)) {
                    HealthConnectClient.SDK_AVAILABLE -> "available"
                    HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED -> "update"
                    else -> "unavailable"
                }
            )
            "openInstall" -> {
                openInstall()
                result.success(null)
            }
            "openSettings" -> {
                try {
                    activity.startActivity(Intent(HealthConnectClient.ACTION_HEALTH_CONNECT_SETTINGS))
                } catch (e: Exception) {
                    openInstall()
                }
                result.success(null)
            }
            "request" -> {
                @Suppress("UNCHECKED_CAST")
                val wanted = (call.arguments as? List<String>).orEmpty().toSet()
                pendingPermissions?.success(null)
                pendingPermissions = result
                try {
                    permissionLauncher.launch(wanted)
                } catch (e: Exception) {
                    pendingPermissions = null
                    result.error("health", e.message, null)
                }
            }
            "appLabel" -> result.success(appLabel(call.arguments as? String ?: ""))
            else -> run(call, result)
        }
    }

    /** The calls that talk to Health Connect itself. */
    private fun run(call: MethodCall, result: MethodChannel.Result) {
        activity.lifecycleScope.launch {
            try {
                result.success(
                    when (call.method) {
                        "granted" -> client.permissionController.getGrantedPermissions().toList()
                        "dailySteps" -> dailySteps(call.int("fromDay"), call.int("toDay"))
                        "sleep" -> sleep(call.long("from"), call.long("to"))
                        "workouts" -> workouts(call.long("from"), call.long("to"))
                        "sessionStats" -> sessionStats(call.long("from"), call.long("to"))
                        "heartRate" -> heartRate(call.long("from"), call.long("to"))
                        "weights" -> weights(call.long("from"))
                        "upsertWorkout" -> upsertWorkout(call)
                        "upsertWeight" -> upsertWeight(call)
                        "delete" -> delete(call)
                        else -> {
                            result.notImplemented()
                            return@launch
                        }
                    }
                )
            } catch (e: SecurityException) {
                result.error("denied", e.message, null)
            } catch (e: Exception) {
                result.error("health", e.message, null)
            }
        }
    }

    private suspend fun dailySteps(fromDay: Int, toDay: Int): List<Map<String, Any>> {
        val rows = client.aggregateGroupByPeriod(
            AggregateGroupByPeriodRequest(
                metrics = setOf(StepsRecord.COUNT_TOTAL),
                timeRangeFilter = TimeRangeFilter.between(day(fromDay).atStartOfDay(), day(toDay).atStartOfDay()),
                timeRangeSlicer = Period.ofDays(1),
            )
        )
        return rows.mapNotNull { row ->
            val steps = row.result[StepsRecord.COUNT_TOTAL] ?: return@mapNotNull null
            mapOf("day" to dayKey(row.startTime.toLocalDate()), "steps" to steps)
        }
    }

    private suspend fun sleep(from: Long, to: Long): List<Map<String, Any>> =
        readAll(SleepSessionRecord::class, from, to).map {
            mapOf("start" to it.startTime.toEpochMilli(), "end" to it.endTime.toEpochMilli())
        }

    private suspend fun workouts(from: Long, to: Long): List<Map<String, Any?>> =
        readAll(ExerciseSessionRecord::class, from, to)
            .filter { it.metadata.dataOrigin.packageName != activity.packageName }
            .map {
                mapOf(
                    "start" to it.startTime.toEpochMilli(),
                    "end" to it.endTime.toEpochMilli(),
                    "type" to it.exerciseType,
                    "title" to it.title,
                    "origin" to it.metadata.dataOrigin.packageName,
                )
            }

    private suspend fun sessionStats(from: Long, to: Long): Map<String, Any?> {
        val granted = client.permissionController.getGrantedPermissions()
        val heart = READ_HEART_RATE in granted
        val calories = READ_ACTIVE_CALORIES in granted
        if (!heart && !calories) return emptyMap()
        val metrics = buildSet {
            if (heart) {
                add(HeartRateRecord.BPM_AVG)
                add(HeartRateRecord.BPM_MAX)
            }
            if (calories) add(ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL)
        }
        val r = client.aggregate(AggregateRequest(metrics, range(from, to)))
        return mapOf(
            "avgHr" to r[HeartRateRecord.BPM_AVG],
            "maxHr" to r[HeartRateRecord.BPM_MAX],
            "kcal" to r[ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL]?.inKilocalories,
            "origins" to r.dataOrigins.map { it.packageName },
        )
    }

    private suspend fun heartRate(from: Long, to: Long): List<List<Long>> =
        readAll(HeartRateRecord::class, from, to)
            .flatMap { it.samples }
            .map { listOf(it.time.toEpochMilli(), it.beatsPerMinute) }
            .sortedBy { it[0] }

    private suspend fun weights(from: Long): List<Map<String, Any>> =
        readAll(WeightRecord::class, from, System.currentTimeMillis() + 60_000)
            .filter { it.metadata.dataOrigin.packageName != activity.packageName }
            .map {
                mapOf(
                    "time" to it.time.toEpochMilli(),
                    "kg" to it.weight.inKilograms,
                    "origin" to it.metadata.dataOrigin.packageName,
                )
            }

    private suspend fun upsertWorkout(call: MethodCall): Boolean {
        val start = Instant.ofEpochMilli(call.long("start"))
        val end = Instant.ofEpochMilli(call.long("end"))
        // Inserting with an existing client id replaces that record.
        client.insertRecords(
            listOf(
                ExerciseSessionRecord(
                    startTime = start,
                    startZoneOffset = zone.rules.getOffset(start),
                    endTime = end,
                    endZoneOffset = zone.rules.getOffset(end),
                    metadata = Metadata.manualEntry(call.str("id"), call.long("version")),
                    exerciseType = ExerciseSessionRecord.EXERCISE_TYPE_STRENGTH_TRAINING,
                    title = call.argument<String>("title"),
                    notes = call.argument<String>("notes"),
                )
            )
        )
        return true
    }

    private suspend fun upsertWeight(call: MethodCall): Boolean {
        val time = Instant.ofEpochMilli(call.long("time"))
        client.insertRecords(
            listOf(
                WeightRecord(
                    time = time,
                    zoneOffset = zone.rules.getOffset(time),
                    weight = Mass.kilograms(call.argument<Double>("kg") ?: 0.0),
                    metadata = Metadata.manualEntry(call.str("id"), call.long("version")),
                )
            )
        )
        return true
    }

    private suspend fun delete(call: MethodCall): Boolean {
        val type: KClass<out Record> = when (call.str("type")) {
            "weight" -> WeightRecord::class
            else -> ExerciseSessionRecord::class
        }
        val ids = call.argument<List<String>>("ids").orEmpty()
        if (ids.isNotEmpty()) client.deleteRecords(type, emptyList(), ids)
        return true
    }

    private suspend fun <T : Record> readAll(type: KClass<T>, from: Long, to: Long): List<T> {
        val out = mutableListOf<T>()
        var page: String? = null
        do {
            val res = client.readRecords(ReadRecordsRequest(type, range(from, to), pageToken = page))
            out += res.records
            page = res.pageToken?.takeIf { it.isNotEmpty() }
        } while (page != null)
        return out
    }

    private fun appLabel(pkg: String): String? = try {
        val pm = activity.packageManager
        val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getApplicationInfo(pkg, PackageManager.ApplicationInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.getApplicationInfo(pkg, 0)
        }
        pm.getApplicationLabel(info).toString()
    } catch (e: Exception) {
        null
    }

    private fun openInstall() {
        val market = Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$PROVIDER&url=healthconnect%3A%2F%2Fonboarding"))
            .setPackage("com.android.vending")
        try {
            activity.startActivity(market)
        } catch (e: Exception) {
            activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$PROVIDER")))
        }
    }

    private fun range(from: Long, to: Long) =
        TimeRangeFilter.between(Instant.ofEpochMilli(from), Instant.ofEpochMilli(to))

    private fun day(key: Int) = LocalDate.of(key / 10000, key / 100 % 100, key % 100)

    private fun dayKey(d: LocalDate) = d.year * 10000 + d.monthValue * 100 + d.dayOfMonth

    private fun MethodCall.long(name: String): Long = (argument<Any>(name) as Number).toLong()

    private fun MethodCall.int(name: String): Int = (argument<Any>(name) as Number).toInt()

    private fun MethodCall.str(name: String): String = argument<String>(name) ?: ""

    companion object {
        const val PROVIDER = "com.google.android.apps.healthdata"
        const val READ_HEART_RATE = "android.permission.health.READ_HEART_RATE"
        const val READ_ACTIVE_CALORIES = "android.permission.health.READ_ACTIVE_CALORIES_BURNED"
    }
}
