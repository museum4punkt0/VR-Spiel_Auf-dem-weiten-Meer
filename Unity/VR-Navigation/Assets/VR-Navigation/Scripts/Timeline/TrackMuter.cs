using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace HumboldtForum.Timeline
{
    [RequireComponent(typeof(PlayableDirector))]
    public class TrackMuter : MonoBehaviour
    {
        [Header("Good end:")]
        [SerializeField] string[] trackNamesToMuteGood = default;
        [Header("Bad end:")]
        [SerializeField] string[] trackNamesToMuteBad = default;
        [Header("Flags:")]
        [SerializeField] string[] trackNamesToMuteFlags = default;

        public void MuteTracks(int numAssigmentsCompleted)
        {
            PlayableDirector director = GetComponent<PlayableDirector>();
            TimelineAsset timeline = director.playableAsset as TimelineAsset;
            double currentTime = director.time;
            int i = 1;
            List<string> trackNamesToMute = new List<string>(numAssigmentsCompleted == 4 ? trackNamesToMuteGood : trackNamesToMuteBad);
            foreach (string trackName in trackNamesToMuteFlags)
            {
                if (numAssigmentsCompleted < i)
                {
                    trackNamesToMute.Add(trackName);
                }
                i++;
            }
            i = 0;
            foreach (TrackAsset track in timeline.GetOutputTracks())
            {
                bool mute = trackNamesToMute.IndexOf(track.name) >= 0;
                if (track.muted != mute)
                {
                    track.muted = mute;
                    Debug.Log($"{this} {(mute ? "muting" : "unmuting")} track {track}", this);
                    if (track is ActivationTrack)
                    {
                        GameObject binding = director.GetGenericBinding(track) as GameObject;
                        if (binding)
                        {
                            if (mute && binding.activeSelf) // by muting this track we also want to deactivate the thing this track was activating
                            {
                                Debug.Log($"{this} muting track {track}: deactivating {binding}", this);
                                binding.SetActive(false);
                            }
                        }
                    }
                }

                i++;
            }
            director.RebuildGraph();
            director.time = currentTime;
        }
    }
}