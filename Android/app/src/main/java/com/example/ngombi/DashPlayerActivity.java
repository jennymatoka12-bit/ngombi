package com.example.ngombi;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;

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

        playerView = new PlayerView(this);

        setContentView(playerView);

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
