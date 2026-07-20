package com.dbhr.sound1_50.ui.main

import android.app.Application
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.dbhr.sound1_50.data.model.Song

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private var mediaPlayer: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())

    private val _playlist = MutableLiveData<List<Song>>(emptyList())
    val playlist: LiveData<List<Song>> = _playlist

    private val _isMusicPlaying = MutableLiveData<Boolean>(false)
    val isMusicPlaying: LiveData<Boolean> = _isMusicPlaying

    private val _songPosition = MutableLiveData<Int>(0)
    val songPosition: LiveData<Int> = _songPosition

    private val _songDuration = MutableLiveData<Int>(0)
    val songDuration: LiveData<Int> = _songDuration

    private val _currentSongIndex = MutableLiveData<Int>(-1)
    val currentSongIndex: LiveData<Int> = _currentSongIndex

    private val _volumeL = MutableLiveData<Int>(80)
    val volumeL: LiveData<Int> = _volumeL

    private val _volumeR = MutableLiveData<Int>(80)
    val volumeR: LiveData<Int> = _volumeR

    private val _isMuted = MutableLiveData<Boolean>(false)
    val isMuted: LiveData<Boolean> = _isMuted

    private val _bpm = MutableLiveData<Double>(120.00)
    val bpm: LiveData<Double> = _bpm

    private val _isMetronomePlaying = MutableLiveData<Boolean>(false)
    val isMetronomePlaying: LiveData<Boolean> = _isMetronomePlaying

    private val memoryPresets = mapOf(1 to 60.00, 2 to 90.00, 3 to 120.00, 4 to 144.00)

    private val updateProgressAction = object : Runnable {
        override fun run() {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    _songPosition.value = it.currentPosition
                    handler.postDelayed(this, 1000)
                }
            }
        }
    }

    fun addSong(song: Song) {
        val currentList = _playlist.value?.toMutableList() ?: mutableListOf()
        currentList.add(song)
        _playlist.value = currentList
        if (_currentSongIndex.value == -1) {
            _currentSongIndex.value = 0
            prepareSong(0, false)
        }
    }

    fun removeCurrentSong() {
        val index = _currentSongIndex.value ?: -1
        val currentList = _playlist.value?.toMutableList() ?: mutableListOf()
        if (index in currentList.indices) {
            currentList.removeAt(index)
            _playlist.value = currentList
            if (currentList.isEmpty()) {
                stopMusic()
                _currentSongIndex.value = -1
            } else {
                val nextIndex = if (index >= currentList.size) currentList.size - 1 else index
                _currentSongIndex.value = nextIndex
                prepareSong(nextIndex, _isMusicPlaying.value == true)
            }
        }
    }

    private fun prepareSong(index: Int, playImmediately: Boolean) {
        val song = _playlist.value?.getOrNull(index) ?: return
        mediaPlayer?.release()
        try {
            mediaPlayer = MediaPlayer().apply {
                setDataSource(getApplication(), song.uri)
                prepare()
                _songDuration.value = duration
                _songPosition.value = 0
                setOnCompletionListener { nextSong() }
                updateVolume()
                if (playImmediately) {
                    start()
                    _isMusicPlaying.value = true
                    startUpdatingProgress()
                } else {
                    _isMusicPlaying.value = false
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun toggleMusicPlayback() {
        if (_playlist.value.isNullOrEmpty()) return
        
        if (mediaPlayer == null && (_currentSongIndex.value ?: -1) >= 0) {
            prepareSong(_currentSongIndex.value!!, true)
            return
        }

        mediaPlayer?.let {
            if (it.isPlaying) {
                it.pause()
                _isMusicPlaying.value = false
                stopUpdatingProgress()
            } else {
                it.start()
                _isMusicPlaying.value = true
                startUpdatingProgress()
            }
        }
    }

    private fun startUpdatingProgress() {
        handler.removeCallbacks(updateProgressAction)
        handler.post(updateProgressAction)
    }

    private fun stopUpdatingProgress() {
        handler.removeCallbacks(updateProgressAction)
    }

    fun restartSong() {
        mediaPlayer?.seekTo(0)
        _songPosition.value = 0
    }

    fun nextSong() {
        val currentList = _playlist.value ?: return
        if (currentList.isEmpty()) return
        val nextIndex = ((_currentSongIndex.value ?: 0) + 1) % currentList.size
        _currentSongIndex.value = nextIndex
        prepareSong(nextIndex, _isMusicPlaying.value == true)
    }

    fun prevSong() {
        val currentList = _playlist.value ?: return
        if (currentList.isEmpty()) return
        var prevIndex = (_currentSongIndex.value ?: 0) - 1
        if (prevIndex < 0) prevIndex = currentList.size - 1
        _currentSongIndex.value = prevIndex
        prepareSong(prevIndex, _isMusicPlaying.value == true)
    }

    fun seekTo(position: Int) {
        mediaPlayer?.seekTo(position)
        _songPosition.value = position
    }

    private fun stopMusic() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        _isMusicPlaying.value = false
        stopUpdatingProgress()
        _songPosition.value = 0
        _songDuration.value = 0
    }

    private fun updateVolume() {
        if (_isMuted.value == true) {
            mediaPlayer?.setVolume(0f, 0f)
        } else {
            val left = (_volumeL.value ?: 80) / 100f
            val right = (_volumeR.value ?: 80) / 100f
            mediaPlayer?.setVolume(left, right)
        }
    }

    fun setVolumeL(volume: Int) {
        _volumeL.value = volume
        updateVolume()
    }

    fun setVolumeR(volume: Int) {
        _volumeR.value = volume
        updateVolume()
    }

    fun toggleMute(muted: Boolean) {
        _isMuted.value = muted
        updateVolume()
    }

    fun startMetronome() { _isMetronomePlaying.value = true }
    fun stopMetronome() { _isMetronomePlaying.value = false }
    fun loadPreset(presetNumber: Int) { memoryPresets[presetNumber]?.let { _bpm.value = it } }

    override fun onCleared() {
        super.onCleared()
        mediaPlayer?.release()
        handler.removeCallbacksAndMessages(null)
    }
}
