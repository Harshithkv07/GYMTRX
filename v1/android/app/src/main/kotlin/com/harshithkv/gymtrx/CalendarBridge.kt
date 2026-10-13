package com.harshithkv.gymtrx

import android.Manifest
import android.content.ContentUris
import android.content.pm.PackageManager
import android.provider.CalendarContract
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.lifecycleScope
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import java.time.ZoneId
import java.time.ZoneOffset
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Reads holidays from the calendars already synced to the phone (for
 * example Google Calendar's "Holidays in India"), over `gymtrx/calendar`.
 * Read-only: GYMTRX never writes to the calendar.
 */
class CalendarBridge(private val activity: FragmentActivity) : MethodChannel.MethodCallHandler {

    private var pending: MethodChannel.Result? = null

    private val permissionLauncher: ActivityResultLauncher<String> =
        activity.registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            pending?.success(granted)
            pending = null
        }

    private val allowed: Boolean
        get() = ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_CALENDAR) ==
            PackageManager.PERMISSION_GRANTED

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasPermission" -> result.success(allowed)
            "requestPermission" -> {
                if (allowed) {
                    result.success(true)
                    return
                }
                pending?.success(false)
                pending = result
                permissionLauncher.launch(Manifest.permission.READ_CALENDAR)
            }
            "calendars" -> io(result) { calendars() }
            "allDayEvents" -> io(result) {
                @Suppress("UNCHECKED_CAST")
                val ids = (call.argument<List<Any>>("calendars")).orEmpty().map { it.toString() }
                events(ids, (call.argument<Any>("from") as Number).toLong(), (call.argument<Any>("to") as Number).toLong())
            }
            else -> result.notImplemented()
        }
    }

    private fun io(result: MethodChannel.Result, block: () -> Any?) {
        if (!allowed) {
            result.error("denied", "Calendar permission not granted", null)
            return
        }
        activity.lifecycleScope.launch {
            try {
                result.success(withContext(Dispatchers.IO) { block() })
            } catch (e: Exception) {
                result.error("calendar", e.message, null)
            }
        }
    }

    private fun calendars(): List<Map<String, Any?>> {
        val out = mutableListOf<Map<String, Any?>>()
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.CALENDAR_COLOR,
        )
        activity.contentResolver.query(CalendarContract.Calendars.CONTENT_URI, projection, null, null, null)?.use { c ->
            while (c.moveToNext()) {
                out += mapOf(
                    "id" to c.getLong(0).toString(),
                    "name" to (c.getString(1) ?: ""),
                    "account" to (c.getString(2) ?: ""),
                    "color" to c.getInt(3),
                )
            }
        }
        return out
    }

    /** Every day covered by an event in [ids] between [from] and [to], with its title. */
    private fun events(ids: List<String>, from: Long, to: Long): List<Map<String, Any>> {
        if (ids.isEmpty()) return emptyList()
        val uri = CalendarContract.Instances.CONTENT_URI.buildUpon().also {
            ContentUris.appendId(it, from)
            ContentUris.appendId(it, to)
        }.build()
        val projection = arrayOf(
            CalendarContract.Instances.TITLE,
            CalendarContract.Instances.BEGIN,
            CalendarContract.Instances.END,
            CalendarContract.Instances.ALL_DAY,
        )
        val selection = "${CalendarContract.Instances.CALENDAR_ID} IN (${ids.joinToString(",") { "?" }})"
        val out = mutableListOf<Map<String, Any>>()
        activity.contentResolver.query(uri, projection, selection, ids.toTypedArray(), null)?.use { c ->
            while (c.moveToNext()) {
                val title = c.getString(0) ?: continue
                val allDay = c.getInt(3) == 1
                // All-day events are stored at UTC midnight; timed ones are local.
                val zone: ZoneId = if (allDay) ZoneOffset.UTC else ZoneId.systemDefault()
                var day = Instant.ofEpochMilli(c.getLong(1)).atZone(zone).toLocalDate()
                val endMs = c.getLong(2)
                val last = Instant.ofEpochMilli(if (allDay) endMs - 1 else endMs).atZone(zone).toLocalDate()
                while (!day.isAfter(last)) {
                    out += mapOf("day" to day.year * 10000 + day.monthValue * 100 + day.dayOfMonth, "title" to title)
                    day = day.plusDays(1)
                }
            }
        }
        return out
    }
}
