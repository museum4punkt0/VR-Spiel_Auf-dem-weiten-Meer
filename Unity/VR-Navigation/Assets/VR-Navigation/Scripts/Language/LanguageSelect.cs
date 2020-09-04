using System;
using System.Linq;
using IJsfontein.Audio;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Audio;
using Valve.VR;

namespace HumboldtForum.Language
{
    public class LanguageSelect : MonoBehaviour
    {
        [SerializeField] AudioLibrary[] audioLibraries = default;
        [SerializeField] LocalizedAudioMixerSnapshot[] audioMixerSnapshots = default;

        public LanguageSelectedEvent OnLanguageSelected;

        private const float FadeDuration = .3f;
        public static Color BlackTransparent = new Color(0, 0, 0, .25f);

        public void SelectLanguage(string language)
        {
            if (Enum.TryParse(language, out IJsfontein.Audio.Language l))
            {
                SelectLanguage(l);
            }
            else
            {
                throw new ArgumentException($"Language {language} not supported");
            }
        }

        public void SelectLanguage(IJsfontein.Audio.Language language)
        {
            audioMixerSnapshots.FirstOrDefault(s => s.locale == language).snapshot.TransitionTo(1);

            foreach (AudioLibrary lib in audioLibraries)
            {
                lib.CurrentLanguage = language;
            }
            Debug.Log($"{this} selected language {language}", this);
            OnLanguageSelected?.Invoke(language);
        }

        public IJsfontein.Audio.Language GetCurrentLanguage()
        {
            return audioLibraries.First().CurrentLanguage;
        }

        public void HeadsetOnChanged(bool isOn)
        {
            if (isOn)
            {
                SteamVR_Fade.Start(Color.clear, FadeDuration);
            }
            else
            {
                SteamVR_Fade.Start(BlackTransparent, FadeDuration);
            }
        }

        [Serializable]
        public class LanguageSelectedEvent : UnityEvent<IJsfontein.Audio.Language>
        {
        }
    }

    [Serializable]
    public struct LocalizedAudioMixerSnapshot
    {
        public IJsfontein.Audio.Language locale;
        public AudioMixerSnapshot snapshot;
    };
}