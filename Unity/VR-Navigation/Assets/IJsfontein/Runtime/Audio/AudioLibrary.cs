using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace IJsfontein.Audio
{
    [CreateAssetMenu]
    public class AudioLibrary : ScriptableObject
    {
        [SerializeField] private AudioEntry[] clips = default;

        public AudioEntry[] Clips { get => clips; }
        public Language CurrentLanguage = Language.any;

        public string GuidForId(string id)
        {
            string guid = default;
            try
            {
                guid = clips.Where(entry => entry.Name == id).Select(e => e.Guid).First();
            }
            catch (Exception)
            {
                Debug.LogError($"{this}: No guid found for id {id}", this);
            }
            return guid;
        }

        public AudioClip ClipForGuid(string guid)
        {
            AudioClip clip = default;
            AudioEntry audioEntry = default;
            try
            {
                audioEntry = clips.Where(entry => entry.Guid == guid).FirstOrDefault();
                clip = audioEntry.LocalizedAudioClips.Where(clips => clips.Language == CurrentLanguage).Select(entry => entry.GetNextClip(audioEntry.Mode)).First();
            }
            catch (Exception)
            {
                Debug.LogError($"{this}: no clip found with guid {guid} and language {CurrentLanguage} ({audioEntry?.Name})", this);
            }

            return clip;
        }

        void OnValidate()
        {
            IEnumerable<string> allGuids = clips.Select(c => c.Guid);
            IEnumerable<string> duplicates = allGuids.Where(g => allGuids.Where(a => a == g).Count() > 1);
            foreach (string dupe in duplicates)
            {
                Debug.Log($"{this} duplicate found {dupe}", this);
                clips.Where(c => c.Guid == dupe).Last().Guid = Guid.NewGuid().ToString();
#if UNITY_EDITOR
                UnityEditor.EditorUtility.SetDirty(this);
#endif
            }
        }
    }

    [Serializable]
    public class AudioEntry
    {
        [SerializeField] string name = default;
        [SerializeField, HideInInspector] string guid = default;
        [SerializeField] LocalizedAudioClip[] localizedAudioClips = default;
        [SerializeField] Mode mode = Mode.random;

        public string Name => name;
        public Mode Mode => mode;
        public LocalizedAudioClip[] LocalizedAudioClips => localizedAudioClips;

        public string Guid
        {
            get
            {
                if (string.IsNullOrEmpty(guid))
                {
                    guid = System.Guid.NewGuid().ToString();
                }
                return guid;
            }
            internal set
            {
                guid = value;
            }
        }

    }

    [Serializable]
    public class LocalizedAudioClip
    {
        [SerializeField] private Language language = Language.any;
        [SerializeField] private AudioClip[] clips = default;

        public Language Language => language;

        private int clipIndex = 0;

        public AudioClip GetNextClip(Mode mode)
        {

            switch (mode)
            {
                case Mode.sequential:
                    return clips[(clipIndex++) % clips.Length];
                case Mode.random:
                default:
                    return GetRandomClip();
            }
        }

        private AudioClip GetRandomClip()
        {
            if (clips.Length == 0)
            {
                return null;
            }
            int r = Mathf.FloorToInt(UnityEngine.Random.value * clips.Length);
            return clips[r];
        }
    }

    public enum Language
    {
        any = -1,
        de,
        en
    }

    public enum Mode
    {
        random = 0,
        sequential = 1
    }
}