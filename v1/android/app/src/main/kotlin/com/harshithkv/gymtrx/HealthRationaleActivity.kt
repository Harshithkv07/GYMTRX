package com.harshithkv.gymtrx

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.util.TypedValue
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView

/**
 * Shown by Health Connect when someone asks how GYMTRX uses their health
 * data. Health Connect only offers its permission screen to apps that have
 * one. Plain native views: it opens outside the Flutter UI.
 */
class HealthRationaleActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val pad = dp(24)
        val column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pad, dp(48), pad, pad)
        }
        column.addView(text(getString(R.string.health_rationale_title), 24f, Color.parseColor("#F4F4F5")))
        for (line in resources.getStringArray(R.array.health_rationale_lines)) {
            column.addView(text(line, 16f, Color.parseColor("#B4B4BA")).apply { setPadding(0, dp(16), 0, 0) })
        }
        setContentView(
            ScrollView(this).apply {
                setBackgroundColor(Color.parseColor("#0A0A0B"))
                addView(column, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            }
        )
    }

    private fun text(value: String, size: Float, color: Int) = TextView(this).apply {
        text = value
        setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        setTextColor(color)
        setLineSpacing(0f, 1.25f)
    }

    private fun dp(v: Int) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), resources.displayMetrics).toInt()
}
