package com.harshithkv.gymtrx.widget

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontFamily
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.harshithkv.gymtrx.MainActivity
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import es.antonborri.home_widget.actionStartActivity
import java.time.LocalDate
import java.time.format.TextStyle as DateTextStyle
import java.util.Locale

class MonthWidgetReceiver : HomeWidgetGlanceWidgetReceiver<MonthWidget>() {
    override val glanceAppWidget = MonthWidget()
}

/**
 * "This month" widget. The app writes gym day keys (yyyymmdd), the accent and
 * the last session label into HomeWidget preferences; "today" is computed
 * here, so the grid stays right after midnight without the app running.
 */
class MonthWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override val sizeMode = SizeMode.Responsive(
        setOf(SMALL, TALL),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val prefs = currentState<HomeWidgetGlanceState>().preferences
            WidgetContent(context, WidgetData.from(prefs))
        }
    }

    companion object {
        val SMALL = DpSize(110.dp, 110.dp)
        val TALL = DpSize(180.dp, 180.dp)
    }
}

// Day (light) and night (dark) palettes, matching the app's two themes.
private val Bg = ColorProvider(day = Color(0xFFFFFFFF), night = Color(0xFF171B21))
private val DotOff = ColorProvider(day = Color(0xFFE1E6E0), night = Color(0xFF29303A))
private val Future = ColorProvider(day = Color(0xFFF0F3EF), night = Color(0xFF1E232A))
private val TodayDot = ColorProvider(day = Color(0xFF161B26), night = Color(0xFFF2F4F3))
private val Ink = ColorProvider(day = Color(0xFF161B26), night = Color(0xFF283141))
private val Text1 = ColorProvider(day = Color(0xFF12161D), night = Color(0xFFF2F4F3))
private val Text2 = ColorProvider(day = Color(0xFF646B73), night = Color(0xFF9AA2A9))
private val Tag = ColorProvider(day = Color(0xFFE5533D), night = Color(0xFFFF7A63))

private data class WidgetData(
    val days: Set<Int>,
    val accent: ColorProvider,
    /** The "+" on the ink button: the accent, or white when the accent is too dark to read. */
    val plus: ColorProvider,
    val weekStart: Int,
    val lastLabel: String?,
) {
    companion object {
        private fun parse(value: String?, fallback: Long) =
            runCatching { Color(android.graphics.Color.parseColor(value)) }.getOrDefault(Color(fallback))

        fun from(prefs: SharedPreferences): WidgetData {
            val day = parse(prefs.getString("accent", null), 0xFFC6F24E)
            val night = parse(prefs.getString("accentDark", null), 0xFFD4FF3F)
            fun onInk(c: Color) = if (c.luminance() < 0.25f) Color.White else c
            return WidgetData(
                days = prefs.getString("days", "").orEmpty().split(',').mapNotNull { it.toIntOrNull() }.toSet(),
                accent = ColorProvider(day = day, night = night),
                plus = ColorProvider(day = onInk(day), night = onInk(night)),
                weekStart = prefs.getString("weekStart", "1")?.toIntOrNull() ?: 1,
                lastLabel = prefs.getString("lastLabel", null),
            )
        }
    }
}

private fun LocalDate.key() = year * 10000 + monthValue * 100 + dayOfMonth

@Composable
private fun WidgetContent(context: Context, data: WidgetData) {
    val today = LocalDate.now()
    val monthStart = today.withDayOfMonth(1)
    val monthCount = (1..today.lengthOfMonth()).count { data.days.contains(monthStart.withDayOfMonth(it).key()) }
    val openApp = actionStartActivity<MainActivity>(context, Uri.parse("gymtrx://open"))
    val size = LocalSize.current
    val showGrid = size.height >= 170.dp && size.width >= 170.dp

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Bg)
            .cornerRadius(26.dp)
            .padding(14.dp)
            .clickable(openApp),
    ) {
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = GlanceModifier.defaultWeight()) {
                Text(
                    text = today.month.getDisplayName(DateTextStyle.FULL, Locale.getDefault()).uppercase(),
                    style = TextStyle(color = Tag, fontSize = 10.sp, fontWeight = FontWeight.Medium),
                    maxLines = 1,
                )
                Text(
                    text = if (monthCount == 1) "1 session" else "$monthCount sessions",
                    style = TextStyle(color = Text1, fontSize = 13.sp, fontWeight = FontWeight.Medium),
                    maxLines = 1,
                )
            }
            AddButton(context, data.plus)
        }
        if (showGrid) {
            Box(modifier = GlanceModifier.defaultWeight().fillMaxWidth(), contentAlignment = Alignment.Center) {
                // Padding (28) and the header row (~44) come off the available space.
                MonthGrid(today, data, size.width - 28.dp, size.height - 72.dp)
            }
        } else {
            Spacer(GlanceModifier.defaultWeight())
            Text(
                text = "$monthCount",
                style = TextStyle(
                    color = Text1,
                    fontSize = 36.sp,
                    fontWeight = FontWeight.Medium,
                    fontFamily = FontFamily.Monospace,
                ),
            )
            Text(
                text = data.lastLabel ?: "Nothing logged yet",
                style = TextStyle(color = Text2, fontSize = 11.sp),
                maxLines = 2,
            )
        }
    }
}

@Composable
private fun AddButton(context: Context, plus: ColorProvider) {
    Box(
        modifier = GlanceModifier
            .size(32.dp)
            .background(Ink)
            .cornerRadius(16.dp)
            .clickable(actionStartActivity<MainActivity>(context, Uri.parse("gymtrx://log"))),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = "+",
            style = TextStyle(color = plus, fontSize = 18.sp, fontWeight = FontWeight.Bold),
        )
    }
}

/** Seven columns of round day dots: logged days in the accent, today in ink. */
@Composable
private fun MonthGrid(today: LocalDate, data: WidgetData, width: Dp, height: Dp) {
    val first = today.withDayOfMonth(1)
    val blanks = (first.dayOfWeek.value - data.weekStart + 7) % 7
    val total = today.lengthOfMonth()
    val rows = (blanks + total + 6) / 7
    // Square cells that fit both directions, so 6-row months never clip.
    val cell = minOf(width / 7, height / rows)
    val dot = cell - 5.dp

    Column {
        for (r in 0 until rows) {
            Row {
                for (c in 0 until 7) {
                    val day = r * 7 + c - blanks + 1
                    Box(modifier = GlanceModifier.width(cell).height(cell), contentAlignment = Alignment.Center) {
                        if (day in 1..total) {
                            val date = first.withDayOfMonth(day)
                            val logged = data.days.contains(date.key())
                            val color = when {
                                logged -> data.accent
                                date == today -> TodayDot
                                date.isAfter(today) -> Future
                                else -> DotOff
                            }
                            // Unlogged days are smaller dots, like the app's dot-matrix calendar.
                            val d = if (logged || date == today) dot else dot * 0.55f
                            Box(modifier = GlanceModifier.size(d).background(color).cornerRadius(d / 2)) {}
                        }
                    }
                }
            }
        }
    }
}
