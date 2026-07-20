package com.dbhr.sound1_50.ui.main

import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import android.widget.Button
import android.widget.SeekBar
import android.widget.TextView
import android.widget.ToggleButton
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.ViewModelProvider
import com.dbhr.sound1_50.R
import com.dbhr.sound1_50.data.model.Song
import java.util.Locale

class MainActivity : ComponentActivity() {

    private lateinit var viewModel: MainViewModel

    private lateinit var tvFileList: TextView
    private lateinit var sbSongPosition: SeekBar
    private lateinit var btnPrev: Button
    private lateinit var btnRew: Button
    private lateinit var btnRestart: Button
    private lateinit var btnPlayMusic: Button
    private lateinit var btnNext: Button
    private lateinit var btnAddSong: Button
    private lateinit var btnRemoveSong: Button

    private lateinit var toggleMute: ToggleButton
    private lateinit var sbVolumeL: SeekBar
    private lateinit var sbVolumeR: SeekBar

    private lateinit var tvBpmDisplay: TextView
    private lateinit var btnPreset1: Button
    private lateinit var btnPreset2: Button
    private lateinit var btnPreset3: Button
    private lateinit var btnPreset4: Button
    private lateinit var btnMetronomeStop: Button
    private lateinit var btnMetronomePlay: Button

    private val pickAudioLauncher = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        uri?.let {
            val fileName = getFileName(it) ?: "Unknown Song"
            viewModel.addSong(Song(it, fileName))
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        viewModel = ViewModelProvider(this).get(MainViewModel::class.java)

        initViews()
        setupClickListeners()
        setupObservers()
    }

    private fun initViews() {
        tvFileList = findViewById(R.id.tv_file_list)
        sbSongPosition = findViewById(R.id.sb_song_position)
        btnPrev = findViewById(R.id.btn_prev)
        btnRew = findViewById(R.id.btn_rew)
        btnRestart = findViewById(R.id.btn_restart)
        btnPlayMusic = findViewById(R.id.btn_play_music)
        btnNext = findViewById(R.id.btn_next)
        btnAddSong = findViewById(R.id.btn_add_song)
        btnRemoveSong = findViewById(R.id.btn_remove_song)

        toggleMute = findViewById(R.id.toggle_mute)
        sbVolumeL = findViewById(R.id.sb_volume_l)
        sbVolumeR = findViewById(R.id.sb_volume_r)

        tvBpmDisplay = findViewById(R.id.tv_bpm_display)
        btnPreset1 = findViewById(R.id.btn_preset_1)
        btnPreset2 = findViewById(R.id.btn_preset_2)
        btnPreset3 = findViewById(R.id.btn_preset_3)
        btnPreset4 = findViewById(R.id.btn_preset_4)
        btnMetronomeStop = findViewById(R.id.btn_metronome_stop)
        btnMetronomePlay = findViewById(R.id.btn_metronome_play)
    }

    private fun setupClickListeners() {
        btnAddSong.setOnClickListener { pickAudioLauncher.launch("audio/*") }
        btnRemoveSong.setOnClickListener { viewModel.removeCurrentSong() }

        btnPlayMusic.setOnClickListener { viewModel.toggleMusicPlayback() }
        btnRestart.setOnClickListener { viewModel.restartSong() }
        btnNext.setOnClickListener { viewModel.nextSong() }
        btnPrev.setOnClickListener { viewModel.prevSong() }

        btnRew.setOnClickListener {
            val currentPos = viewModel.songPosition.value ?: 0
            viewModel.seekTo((currentPos - 5000).coerceAtLeast(0))
        }

        sbSongPosition.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) viewModel.seekTo(progress)
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        toggleMute.setOnCheckedChangeListener { _, isChecked -> viewModel.toggleMute(isChecked) }

        sbVolumeL.setOnSeekBarChangeListener(createVolumeListener { vol -> viewModel.setVolumeL(vol) })
        sbVolumeR.setOnSeekBarChangeListener(createVolumeListener { vol -> viewModel.setVolumeR(vol) })

        btnMetronomePlay.setOnClickListener { viewModel.startMetronome() }
        btnMetronomeStop.setOnClickListener { viewModel.stopMetronome() }

        btnPreset1.setOnClickListener { viewModel.loadPreset(1) }
        btnPreset2.setOnClickListener { viewModel.loadPreset(2) }
        btnPreset3.setOnClickListener { viewModel.loadPreset(3) }
        btnPreset4.setOnClickListener { viewModel.loadPreset(4) }
    }

    private fun setupObservers() {
        viewModel.isMusicPlaying.observe(this) { playing ->
            btnPlayMusic.text = if (playing) "PAUSE" else "PLAY"
        }

        viewModel.songPosition.observe(this) { position ->
            sbSongPosition.progress = position
        }

        viewModel.songDuration.observe(this) { duration ->
            sbSongPosition.max = duration
        }

        viewModel.playlist.observe(this) { updateCrtMonitorLayout() }
        viewModel.currentSongIndex.observe(this) { updateCrtMonitorLayout() }

        viewModel.volumeL.observe(this) { vol -> sbVolumeL.progress = vol }
        viewModel.volumeR.observe(this) { vol -> sbVolumeR.progress = vol }
        viewModel.isMuted.observe(this) { muted -> toggleMute.isChecked = muted }

        viewModel.bpm.observe(this) { bpmValue ->
            tvBpmDisplay.text = String.format(Locale.US, "%.2f", bpmValue)
        }

        viewModel.isMetronomePlaying.observe(this) { playing ->
            btnMetronomePlay.isEnabled = !playing
            btnMetronomeStop.isEnabled = playing
        }
    }

    private fun createVolumeListener(onVolumeChanged: (Int) -> Unit): SeekBar.OnSeekBarChangeListener {
        return object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) onVolumeChanged(progress)
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        }
    }

    private fun updateCrtMonitorLayout() {
        val songs = viewModel.playlist.value ?: emptyList()
        val activeIndex = viewModel.currentSongIndex.value ?: -1

        if (songs.isEmpty()) {
            tvFileList.text = "[EMPTY PLAYLIST]\nADD SONGS TO START..."
            return
        }

        val builder = StringBuilder()
        songs.forEachIndexed { index, song ->
            val prefix = if (index == activeIndex) "> " else "  "
            builder.append(prefix).append(index + 1).append(". ").append(song.title).append("\n")
        }
        tvFileList.text = builder.toString().trimEnd()
    }

    private fun getFileName(uri: Uri): String? {
        var result: String? = null
        if (uri.scheme == "content") {
            val cursor: Cursor? = contentResolver.query(uri, null, null, null, null)
            try {
                if (cursor != null && cursor.moveToFirst()) {
                    val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (index != -1) result = cursor.getString(index)
                }
            } finally {
                cursor?.close()
            }
        }
        if (result == null) {
            result = uri.path
            val cut = result?.lastIndexOf('/') ?: -1
            if (cut != -1) {
                result = result?.substring(cut + 1)
            }
        }
        return result
    }
}
