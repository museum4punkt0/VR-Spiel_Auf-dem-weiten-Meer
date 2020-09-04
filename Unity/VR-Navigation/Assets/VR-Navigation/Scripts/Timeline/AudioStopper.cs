using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

namespace HumboldtForum.Timeline
{
    public class AudioStopper : MonoBehaviour
    {
        [SerializeField] bool stopWhenTimelineStarts = true;
        [SerializeField] string[] tagsToStop = default;

        void Awake()
        {
            if (stopWhenTimelineStarts)
            {
                PlayableDirector timeline = GetComponent<PlayableDirector>();
                if (timeline)
                {
                    timeline.played += OnTimelinePlayed;
                }
            }
        }

        private void OnTimelinePlayed(PlayableDirector t)
        {
            StopSounds();
        }

        public void StopSounds()
        {
            AudioSource[] sources = FindObjectsOfType<AudioSource>();
            foreach (string t in tagsToStop)
            {
                foreach (AudioSource s in sources)
                {
                    if (s.CompareTag(t))
                    {
                        if (s.isPlaying)
                        {
                            s.Stop();
                            Debug.Log($"{this}: stopped sound {s}", this);
                        }
                    }
                }
            }
        }
    }
}