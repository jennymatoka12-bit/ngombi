package com.example.ngombi;

import android.content.Intent;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "ngombi/player";
    private static final String RADIO_CHANNEL = "ngombi/radio";

    @Override
    public void configureFlutterEngine(
            @NonNull FlutterEngine flutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {

            if ("setKeepScreenOn".equals(call.method)) {
                Boolean enabled = call.argument("enabled");

                if (Boolean.TRUE.equals(enabled)) {
                    getWindow().addFlags(
                            android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    );
                } else {
                    getWindow().clearFlags(
                            android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    );
                }

                result.success(true);
                return;
            }

            if ("playDash".equals(call.method)) {
                String url = call.argument("url");
                String userAgent = call.argument("userAgent");

                if (url == null || url.isEmpty()) {
                    result.error("INVALID_URL", "URL DASH manquante", null);
                    return;
                }

                Intent intent = new Intent(MainActivity.this, DashPlayerActivity.class);
                intent.putExtra("url", url);
                intent.putExtra("userAgent", userAgent);
                startActivity(intent);
                result.success(true);
            } else {
                result.notImplemented();
            }
        });

        // Keep the existing player channel intact. This separate channel is
        // used only for handing the currently playing radio to Android's
        // native media-session notification when the app goes to background.
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                RADIO_CHANNEL
        ).setMethodCallHandler((call, result) -> {
            if ("startBackgroundRadio".equals(call.method)) {
                String url = call.argument("url");
                String title = call.argument("title");

                if (url == null || url.trim().isEmpty()) {
                    result.error("INVALID_URL", "URL de radio manquante", null);
                    return;
                }

                Intent intent = new Intent(MainActivity.this, RadioPlaybackService.class);
                intent.setAction(RadioPlaybackService.ACTION_START_RADIO);
                intent.putExtra(RadioPlaybackService.EXTRA_URL, url);
                intent.putExtra(RadioPlaybackService.EXTRA_TITLE, title);

                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        ContextCompat.startForegroundService(MainActivity.this, intent);
                    } else {
                        startService(intent);
                    }
                    result.success(true);
                } catch (Exception error) {
                    result.error("RADIO_SERVICE_ERROR",
                            "Impossible de démarrer la lecture radio en arrière-plan",
                            error.getMessage());
                }
                return;
            }

            if ("stopBackgroundRadio".equals(call.method)) {
                Intent intent = new Intent(MainActivity.this, RadioPlaybackService.class);
                intent.setAction(RadioPlaybackService.ACTION_STOP_RADIO);
                try {
                    startService(intent);
                    result.success(true);
                } catch (Exception error) {
                    stopService(new Intent(MainActivity.this, RadioPlaybackService.class));
                    result.success(true);
                }
                return;
            }

            result.notImplemented();
        });
    }
}
