using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace HumboldtForum.Timeline
{
    internal static class TimelineMarkersExtension
    {
        public static Dictionary<string, LabelMarker> LabelMarkerTimes(this PlayableDirector timeline)
        {
            IEnumerable<LabelMarker> markers = timeline.SortedMarkers();
            return markers.ToDictionary(m => m.Label, m => m);
        }

        private static IEnumerable<LabelMarker> SortedMarkers(this PlayableDirector timeline)
        {
            TimelineAsset t = timeline.playableAsset as TimelineAsset;
            IEnumerable<LabelMarker> markers = t.markerTrack.GetMarkers().Where(m => m is LabelMarker).Select(m => m as LabelMarker).OrderBy(m => m.time);
            return markers;
        }

        public static bool IsPastMarker(this PlayableDirector timeline, LabelMarker marker)
        {
            return marker.time < timeline.time;
        }

        /// <summary>
        /// Jumps to the given time and evaluates there
        /// </summary>
        public static void Seek(this PlayableDirector timeline, double time)
        {
            timeline.time = time;
            timeline.Evaluate();
        }

        /// <summary>
        /// Jumps to the given label's time and evaluates there
        /// </summary>
        public static void Seek(this PlayableDirector timeline, LabelMarker label)
        {
            try
            {
                timeline.Seek(label.time);
            }
            catch (Exception)
            {
                throw new ArgumentException("Label not found");
            }
        }

        public static void SkipToNextMarker(this PlayableDirector timeline)
        {
            LabelMarker marker = default;
            foreach (var m in timeline.SortedMarkers())
            {
                marker = m;
                Debug.Log($"{timeline} checking {m.Label}");
                if (timeline.time < m.time)
                {
                    Debug.Log($"{timeline} next marker is {m.Label}");
                    break;
                }
            }
            if (marker)
            {
                Debug.Log($"{timeline} skip to {marker.Label}");
                timeline.Seek(marker);
                timeline.Pause();
            }
        }
    }
}