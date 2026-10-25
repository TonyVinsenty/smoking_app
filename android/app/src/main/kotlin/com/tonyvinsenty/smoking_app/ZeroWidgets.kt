package com.tonyvinsenty.smoking_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Build
import android.icu.text.PluralRules
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.NumberFormat
import java.util.Locale

/** Home-screen widgets. Dart hands over rates and texts (see lib/app/home_widget.dart); the time is counted here. */
object ZeroWidgets {
    private const val PREFS = "zero_widget"
    private const val KEY = "payload"

    /** The extra quick_actions reads on launch: the widget's SOS goes the same way as the icon menu. */
    const val SHORTCUT_EXTRA = "some unique action key"

    private val providers = listOf(SosWidget::class.java, TimeSosWidget::class.java, TimeWidget::class.java, WideWidget::class.java)

    fun save(context: Context, payload: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(KEY, payload).apply()
        renderAll(context)
    }

    fun renderAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        var any = false
        for (provider in providers) {
            val ids = manager.getAppWidgetIds(ComponentName(context, provider))
            if (ids.isNotEmpty()) any = true
            for (id in ids) manager.updateAppWidget(id, render(context, provider))
        }
        tick(context, any)
    }

    /** Redraws every minute while any widget is placed; a non-waking alarm, so a sleeping phone is left alone. */
    private fun tick(context: Context, on: Boolean) {
        val alarms = context.getSystemService(AlarmManager::class.java)
        val intent = PendingIntent.getBroadcast(
            context, 0, Intent(context, WidgetTicker::class.java), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        if (!on) return alarms.cancel(intent)
        val nextMinute = (System.currentTimeMillis() / MINUTE + 1) * MINUTE
        alarms.setRepeating(AlarmManager.RTC, nextMinute, MINUTE, intent)
    }

    private fun render(context: Context, provider: Class<*>): RemoteViews {
        val data = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)?.let(::JSONObject)
        val layout = when (provider) {
            SosWidget::class.java -> R.layout.widget_sos
            TimeSosWidget::class.java -> R.layout.widget_time_sos
            TimeWidget::class.java -> R.layout.widget_time
            else -> R.layout.widget_wide
        }
        val views = RemoteViews(context.packageName, layout)
        views.setOnClickPendingIntent(R.id.widget_root, open(context, null))
        views.setOnClickPendingIntent(R.id.widget_sos, open(context, "sos"))
        if (data != null) {
            fill(context, views, data)
        } else {
            // Before onboarding the layout's preview numbers must not show: just the name, a tap opens the app.
            for (id in listOf(R.id.widget_label, R.id.widget_days_word, R.id.widget_clock, R.id.widget_money, R.id.widget_units)) {
                views.setTextViewText(id, "")
            }
            views.setTextViewTextSize(R.id.widget_days, TypedValue.COMPLEX_UNIT_DIP, 24f)
            views.setTextViewText(R.id.widget_days, "Zero")
        }
        return views
    }

    private fun fill(context: Context, views: RemoteViews, data: JSONObject) {
        val light = data.getJSONObject("light")
        val dark = data.getJSONObject("dark")
        // The phone's theme, not the app's own resources: those can lag behind while the app is not running.
        val night = Resources.getSystem().configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
        fun paint(id: Int, method: String, name: String) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+: the home screen swaps light and dark itself, the moment the theme changes.
            views.setColorInt(id, method, light.getInt(name), dark.getInt(name))
        } else {
            views.setInt(id, method, (if (night) dark else light).getInt(name))
        }
        val plural = PluralRules.forLocale(Locale.forLanguageTag(data.getString("locale")))
        val number = NumberFormat.getIntegerInstance(Locale.forLanguageTag(data.getString("locale")))
        fun form(key: String, n: Long) = data.getJSONObject(key).let { it.optString(plural.select(n.toDouble()), it.getString("other")) }

        paint(R.id.widget_bg, "setColorFilter", "card")
        paint(R.id.widget_sos_bg, "setColorFilter", "primary")
        paint(R.id.widget_sos_icon, "setColorFilter", "onPrimary")
        paint(R.id.widget_saved_bg, "setColorFilter", "rewardContainer")
        paint(R.id.widget_units_bg, "setColorFilter", "primaryContainer")
        for (id in listOf(R.id.widget_label, R.id.widget_days_word, R.id.widget_clock, R.id.widget_saved_label, R.id.widget_units_label)) {
            paint(id, "setTextColor", "muted")
        }
        paint(R.id.widget_days, "setTextColor", "primary")
        paint(R.id.widget_sos_text, "setTextColor", "onPrimary")
        paint(R.id.widget_sos_hint, "setTextColor", "onPrimary")
        paint(R.id.widget_money, "setTextColor", "reward")
        paint(R.id.widget_units, "setTextColor", "onPrimaryContainer")

        views.setTextViewText(R.id.widget_label, data.getString("smokeFree"))
        views.setTextViewText(R.id.widget_saved_label, data.getString("saved"))
        views.setTextViewText(R.id.widget_units_label, data.getString("notSmoked"))
        views.setTextViewText(R.id.widget_sos_hint, data.getString("sosShort"))
        views.setTextViewText(R.id.widget_sos_text, data.getString(if (views.layoutId == R.layout.widget_wide) "sosLong" else "sos"))

        val start = if (data.isNull("start")) null else data.getLong("start")
        val showTime = if (start == null) View.GONE else View.VISIBLE
        views.setViewVisibility(R.id.widget_days_word, showTime)
        views.setViewVisibility(R.id.widget_clock, showTime)
        if (start == null) {
            // Between attempts: the big number gives way to «Новая попытка», a tap opens the app to start one.
            views.setTextViewTextSize(R.id.widget_days, TypedValue.COMPLEX_UNIT_DIP, 20f)
            views.setTextViewText(R.id.widget_days, data.getString("noAttempt"))
            views.setTextViewText(R.id.widget_money, "—")
            views.setTextViewText(R.id.widget_units, "—")
            return
        }
        val minutes = maxOf(0L, (System.currentTimeMillis() - start) / MINUTE)
        val days = minutes / MINUTES_PER_DAY
        views.setTextViewText(R.id.widget_days, number.format(days))
        views.setTextViewText(R.id.widget_days_word, form("days", days))
        views.setTextViewText(
            R.id.widget_clock,
            data.getString("clock").replace("{h}", (minutes / 60 % 24).toString()).replace("{m}", (minutes % 60).toString()),
        )
        val money = (data.getDouble("moneyPerDay") * minutes / MINUTES_PER_DAY).toLong()
        views.setTextViewText(R.id.widget_money, data.getString("money").replace("{n}", number.format(money)))
        val units = (data.getDouble("unitsPerDay") * minutes / MINUTES_PER_DAY).toLong()
        views.setTextViewText(R.id.widget_units, form("units", units).replace("{n}", number.format(units)))
    }

    /** Opens Zero (through the enabled icon alias), or SOS when [shortcut] is given. */
    private fun open(context: Context, shortcut: String?): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)!!
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        if (shortcut != null) intent.setAction(Intent.ACTION_RUN).putExtra(SHORTCUT_EXTRA, shortcut)
        return PendingIntent.getActivity(
            context, if (shortcut == null) 0 else 1, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private const val MINUTE = 60_000L
    private const val MINUTES_PER_DAY = 24 * 60L
}

open class ZeroWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) = ZeroWidgets.renderAll(context)

    override fun onDisabled(context: Context) = ZeroWidgets.renderAll(context)
}

class SosWidget : ZeroWidget()

class TimeSosWidget : ZeroWidget()

class TimeWidget : ZeroWidget()

class WideWidget : ZeroWidget()

class WidgetTicker : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) = ZeroWidgets.renderAll(context)
}
