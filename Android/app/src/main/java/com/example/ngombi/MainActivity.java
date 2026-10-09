package com.example.ngombi;

import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "ngombi/player";

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
                    result.error(
                            "INVALID_URL",
                            "URL DASH manquante",
                            null
                    );
                    return;
                }

                Intent intent = new Intent(
                        MainActivity.this,
                        DashPlayerActivity.class
                );

                intent.putExtra(
                        "url",
                        url
                );

                intent.putExtra(
                        "userAgent",
                        userAgent
                );

                startActivity(intent);

                result.success(true);

            } else {
                result.notImplemented();
            }
        });
    }
}
