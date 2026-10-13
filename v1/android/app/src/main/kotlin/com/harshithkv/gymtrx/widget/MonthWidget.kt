package com.harshithkv.gymtrx.widget

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
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

private val Bg = Color(0xFF0A0A0B)
private val Surface = Color(0xFF26262A)
private val Future = Color(0xFF17171A)
private val Text1 = Color(0xFFF4F4F5)
private val Text2 = Color(0xFF8E8E93)
private val OnAccent = Color(0xFF0A0A0B)

private data class WidgetData(
    val days: Set<Int>,
    val accent: Color,
    val weekStart: Int,
    val lastLabel: String?,
) {
    companion object {
        fun from(prefs: SharedPreferences) = WidgetData(
            days = prefs.getString("days", "").orEmpty().split(',').mapNotNull { it.toIntOrNull() }.toSet(),
            accent = runCatching { Color(android.graphics.Color.parseColor(prefs.getString("accent", "#A8C8A0"))) }
                .getOrDefault(Color(0xFFA8C8A0)),
            weekStart = prefs.getString("weekStart", "1")?.toIntOrNull() ?: 1,
            lastLabel = prefs.getString("lastLabel", null),
        )
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
            .cornerRadius(24.dp)
            .padding(14.dp)
            .clickable(openApp),
    ) {
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = GlanceModifier.defaultWeight()) {
                Text(
                    text = today.month.getDisplayName(DateTextStyle.FULL, Locale.getDefault()).uppercase(),
                    style = TextStyle(color = ColorProvider(Text2), fontSize = 10.sp, fontWeight = FontWeight.Medium),
                    maxLines = 1,
                )
                Text(
                    text = if (monthCount == 1) "1 session" else "$monthCount sessions",
                    style = TextStyle(color = ColorProvider(Text1), fontSize = 13.sp, fontWeight = FontWeight.Medium),
                    maxLines = 1,
                )
            }
            AddButton(context, data.accent)
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
                    color = ColorProvider(Text1),
                    fontSize = 36.sp,
                    fontWeight = FontWeight.Medium,
                    fontFamily = FontFamily.Monospace,
                ),
            )
            Text(
                text = data.lastLabel ?: "Nothing logged yet",
                style = TextStyle(color = ColorProvider(Text2), fontSize = 11.sp),
                maxLines = 2,
            )
        }
    }
}

@Composable
private fun AddButton(context: Context, accent: Color) {
    Box(
        modifier = GlanceModifier
            .size(30.dp)
            .background(accent)
            .cornerRadius(15.dp)
            .clickable(actionStartActivity<MainActivity>(context, Uri.parse("gymtrx://log"))),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = "+",
            style = TextStyle(color = ColorProvider(OnAccent), fontSize = 18.sp, fontWeight = FontWeight.Bold),
        )
    }
}

/** Seven columns of day squares; logged days in the accent, today outlined by brightness. */
@Composable
private fun MonthGrid(today: LocalDate, data: WidgetData, width: Dp, height: Dp) {
    val first = today.withDayOfMonth(1)
    val blanks = (first.dayOfWeek.value - data.weekStart + 7) % 7
    val total = today.lengthOfMonth()
    val rows = (blanks + total + 6) / 7
    // Square cells that fit both directions, so 6-row months never clip.
    val cell = minOf(width / 7, height / rows)
    val dot = cell - 4.dp

    Column {
        for (r in 0 until rows) {
            Row {
                for (c in 0 until 7) {
                    val day = r * 7 + c - blanks + 1
                    Box(modifier = GlanceModifier.width(cell).height(cell), contentAlignment = Alignment.Center) {
                        if (day in 1..total) {
                            val date = first.withDayOfMonth(day)
                            val color = when {
                                data.days.contains(date.key()) -> data.accent
                                date == today -> Text2
                                date.isAfter(today) -> Future
                                else -> Surface
                            }
                            Box(
                                modifier = GlanceModifier.size(dot).background(color).cornerRadius(dot / 3),
                            ) {}
                        }
                    }
                }
            }
        }
    }
}
