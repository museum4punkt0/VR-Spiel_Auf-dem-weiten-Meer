using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace HumboldtForum.Language
{
    public class LanguageIndicator : MonoBehaviour
    {
        [SerializeField] GameObject english = default;
        [SerializeField] GameObject german = default;
        [SerializeField] LanguageSelect switcher = default;

        void Awake()
        {
            switcher.OnLanguageSelected.AddListener(ShowCurrentLanguage);
            ShowCurrentLanguage(switcher.GetCurrentLanguage());
        }

        public void ShowCurrentLanguage(IJsfontein.Audio.Language l)
        {
            english.SetActive(l == IJsfontein.Audio.Language.en);
            german.SetActive(l == IJsfontein.Audio.Language.de);
        }
    }
}