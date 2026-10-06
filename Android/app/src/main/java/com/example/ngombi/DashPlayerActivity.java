package com.example.ngombi;

import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.dash.DashMediaSource;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.ui.PlayerView;

@UnstableApi
public class DashPlayerActivity extends AppCompatActivity {

    private ExoPlayer player;
    private PlayerView playerView;

    @Override
    protected void onCreate(
            @Nullable Bundle savedInstanceState
    ) {
        super.onCreate(savedInstanceState);

        FrameLayout root = new FrameLayout(this);

        playerView = new PlayerView(this);
        playerView.setUseController(true);

        root.addView(
                playerView,
                new FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT
                )
        );

        String channelName = getIntent().getStringExtra("channelName");
        String programTitle = getIntent().getStringExtra("programTitle");

        TextView programOverlay = new TextView(this);
        programOverlay.setTextColor(Color.WHITE);
        programOverlay.setTextSize(16);
        programOverlay.setGravity(Gravity.CENTER_VERTICAL);
        programOverlay.setPadding(24, 14, 24, 14);
        programOverlay.setMaxLines(2);
        programOverlay.setEllipsize(android.text.TextUtils.TruncateAt.END);
        programOverlay.setBackgroundColor(0xB3000000);

        String title = programTitle == null ? "" : programTitle.trim();
        String channel = channelName == null ? "" : channelName.trim();

        if (!title.isEmpty() && !channel.isEmpty()) {
            programOverlay.setText(channel + "  •  " + title);
        } else if (!title.isEmpty()) {
            programOverlay.setText(title);
        } else if (!channel.isEmpty()) {
            programOverlay.setText(channel + "  •  EN DIRECT");
        } else {
            programOverlay.setText("EN DIRECT");
        }

        FrameLayout.LayoutParams overlayParams =
                new FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.WRAP_CONTENT
                );
        overlayParams.gravity = Gravity.TOP;
        overlayParams.setMargins(0, 24, 0, 0);

        root.addView(programOverlay, overlayParams);

        setContentView(root);

        String url = getIntent().getStringExtra("url");
        String userAgent =
                getIntent().getStringExtra("userAgent");

        if (url == null || url.isEmpty()) {
            finish();
            return;
        }

        if (userAgent == null || userAgent.isEmpty()) {
            userAgent = "Mozilla/5.0";
        }

        DefaultHttpDataSource.Factory httpDataSourceFactory =
                new DefaultHttpDataSource.Factory()
                        .setUserAgent(userAgent);

        MediaSource.Factory mediaSourceFactory =
                new DashMediaSource.Factory(
                        httpDataSourceFactory
                );

        player = new ExoPlayer.Builder(this)
                .setMediaSourceFactory(mediaSourceFactory)
                .build();

        playerView.setPlayer(player);

        MediaItem mediaItem =
                new MediaItem.Builder()
                        .setUri(Uri.parse(url))
                        .setMimeType(MimeTypes.APPLICATION_MPD)
                        .build();

        player.setMediaItem(mediaItem);

        player.prepare();
        player.play();
    }

    @Override
    protected void onStop() {
        super.onStop();

        if (player != null) {
            player.pause();
        }
    }

    @Override
    protected void onDestroy() {
        if (player != null) {
            player.release();
            player = null;
        }

        super.onDestroy();
    }
}
