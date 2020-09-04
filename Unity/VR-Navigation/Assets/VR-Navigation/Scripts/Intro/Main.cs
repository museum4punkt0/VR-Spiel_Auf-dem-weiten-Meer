using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using HumboldtForum.Language;
using IJsfontein.Audio;
using UnityEngine;
using UnityEngine.SceneManagement;
using Valve.VR;

namespace HumboldtForum.Intro
{
    public class Main : MonoBehaviour
    {
        [SerializeField] AudioLibraryClipPlayer sound = default;
        private const float FADE_DURATION = .3f;

        void Start()
        {
            SteamVR_Fade.Start(LanguageSelect.BlackTransparent, 0);
            sound.GetComponent<AudioSource>().outputAudioMixerGroup.audioMixer.FindSnapshot("DE").TransitionTo(1);
        }

        public void LoadGame()
        {
            SteamVR_Fade.Start(Color.black, FADE_DURATION);
            sound.enabled = false; // will fade out background

            DOVirtual.DelayedCall(FADE_DURATION, () =>
                {
                    SceneManager.LoadSceneAsync("Main");
                }
            );
        }
    }
}