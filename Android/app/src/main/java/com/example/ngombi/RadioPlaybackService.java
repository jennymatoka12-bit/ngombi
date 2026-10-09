package com.example.ngombi;

import android.content.Intent;

import androidx.annotation.Nullable;

import androidx.media3.common.MediaItem;
import androidx.media3.common.MediaMetadata;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.session.MediaSession;
import androidx.media3.session.MediaSessionService;

/**
 * Native playback service so Android can expose NGOMBI as an active media
 * session in the notification shade and lock screen.
 */
public class RadioPlaybackService extends MediaSessionService {
    public static final String ACTION_START_RADIO =
            "com.example.ngombi.action.START_RADIO";
    public static final String ACTION_STOP_RADIO =
            "com.example.ngombi.action.STOP_RADIO";
    public static final String EXTRA_URL = "url";
    public static final String EXTRA_TITLE = "title";

    private ExoPlayer player;
    private MediaSession mediaSession;

    @Override
    public void onCreate() {
        super.onCreate();

        player = new ExoPlayer.Builder(this).build();
        mediaSession = new MediaSession.Builder(this, player).build();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && ACTION_STOP_RADIO.equals(intent.getAction())) {
            if (player != null) {
                player.stop();
                player.clearMediaItems();
            }
            stopSelf();
            return START_NOT_STICKY;
        }

        if (intent != null && ACTION_START_RADIO.equals(intent.getAction())) {
            String url = intent.getStringExtra(EXTRA_URL);
            String title = intent.getStringExtra(EXTRA_TITLE);

            if (url != null && !url.trim().isEmpty() && player != null) {
                MediaMetadata metadata = new MediaMetadata.Builder()
                        .setTitle(title == null || title.trim().isEmpty()
                                ? "Radio en direct" : title)
                        .setArtist("NGOMBI • Radio en direct")
                        .build();

                MediaItem item = new MediaItem.Builder()
                        .setUri(url)
                        .setMediaMetadata(metadata)
                        .build();

                player.setMediaItem(item);
                player.prepare();
                player.play();
            }
        }

        return super.onStartCommand(intent, flags, startId);
    }

    @Nullable
    @Override
    public MediaSession onGetSession(MediaSession.ControllerInfo controllerInfo) {
        return mediaSession;
    }

    @Override
    public void onDestroy() {
        if (mediaSession != null) {
            mediaSession.release();
            mediaSession = null;
        }
        if (player != null) {
            player.release();
            player = null;
        }
        super.onDestroy();
    }
}
