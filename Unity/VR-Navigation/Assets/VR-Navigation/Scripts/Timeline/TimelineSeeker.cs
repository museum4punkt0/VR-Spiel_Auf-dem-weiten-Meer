using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

namespace HumboldtForum.Timeline
{
    [RequireComponent(typeof(PlayableDirector))]
    public class TimelineSeeker : MonoBehaviour
    {
        private PlayableDirector timeline;

        void Awake()
        {
            timeline = GetComponent<PlayableDirector>();
        }

        public void SeekTime(int t)
        {
            timeline.Seek(t);
        }

        public void SeekEnd()
        {
            timeline.Seek(timeline.duration);
        }
    }
}