using System;
using System.Collections.Generic;
using HumboldtForum.VR;
using IJsfontein.Audio;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Serialization;

namespace HumboldtForum.Assignments
{
    public class AssignmentElements : MonoBehaviour
    {
        [FormerlySerializedAs("TurtleTimeline"), SerializeField] PlayableDirector turtleTimeline = default;
        [SerializeField] PlayableDirector poemTimeline = default;
        public GazeButton[] CorrectButtons;
        [FormerlySerializedAs("correctAudio")] public List<AudioLibraryClipPlayer> CorrectAudio;
        [FormerlySerializedAs("incorrectAudio")] public AudioLibraryClipPlayer IncorrectAudio;

        public PlayableDirector TurtleTimeline => turtleTimeline;
        public PlayableDirector PoemTimeline => poemTimeline;
    }
}