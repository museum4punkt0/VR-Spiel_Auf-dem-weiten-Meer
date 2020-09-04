using System;
using System.Collections.Generic;
using System.Linq;
using DG.Tweening;
using HumboldtForum.Assignments;
using HumboldtForum.Timeline;
using HumboldtForum.VR;
using IJsfontein.Audio;
using IJsfontein.GameStates;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.UI;

namespace HumboldtForum.GameStates
{
    internal class GameStateStarsAssignment : GameStateAssignment
    {
        private readonly List<GazeButton> rightStars;
        private readonly PlayableDirector foundTimeline;
        private AudioLibraryClipPlayer playingFeedbackAudio;

        public GameStateStarsAssignment(GameContext gameContext) : base(gameContext, Main.LayerName.StarsAssignment)
        {
            rightStars = new List<GazeButton>(assignmentElements.CorrectButtons);
            foundTimeline = GetComponentForLayer<PlayableDirector>("Found Graphic");
        }

        public override void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            context.DayNightTimeline.Resume();// make it turn to night
            turtleTimeline.stopped += SkipBack;
            context.Boat.SetDrift(.125f);
        }

        public override void Deactivate(AbstractGameState nextState)
        {
            turtleTimeline.stopped -= SkipBack;
            base.Deactivate(nextState);
        }


        private void SkipBack(PlayableDirector d)
        {
            d.Seek(turtleMarkers["Last"]);
        }

        protected override void OnButtonSelected(GazeButton b)
        {
            if (playingFeedbackAudio)
            {
                playingFeedbackAudio.Stop();
                playingFeedbackAudio = default;
            }
            if (rightStars.Remove(b))
            {
                // found one!
                if (assignmentElements.CorrectAudio.Count > 0)
                {
                    SkipTurtle();
                    playingFeedbackAudio = assignmentElements.CorrectAudio.First();
                    playingFeedbackAudio?.Play();
                    assignmentElements.CorrectAudio.RemoveAt(0);
                }
            }
            else if (b.name.Contains("Wrong"))// found a wrong one, but don't want this sound when activating the turtle!
            {
                SkipTurtle();
                assignmentElements.IncorrectAudio?.Play();
            }
            // no more stars to find
            if (rightStars.Count == 0)
            {
                // found all!
                foundTimeline.Resume();
                turtleTimeline.Seek(turtleTimeline.duration);
                // switch all correct stars off again
                foreach (GazeButton star in assignmentElements.CorrectButtons)
                {
                    Image selected = star.GetComponentsInChildren<Image>().FirstOrDefault(i => i.gameObject.name == "Selected");
                    if (selected)
                    {
                        selected.enabled = false;
                    }
                }
                // also disable all gazebuttons
                EnableAllGazeButtons(false);
                foundTimeline.paused += OnFoundTimelineComplete;
                context.SetAssignmentCompleted();
                playingFeedbackAudio.Finished.AddListener(
                    () =>
                    {
                        playingFeedbackAudio.Finished.RemoveAllListeners();
                        playingFeedbackAudio = default;
                    }
                );
            }

        }

        private void OnFoundTimelineComplete(PlayableDirector timeline)
        {
            timeline.paused -= OnFoundTimelineComplete;
            timeline.Resume(); // keep found graphic visible for a while
            context.SetSailToAssignmentState(context.AssignmentIndex + 1, 1.5f);
        }
    }
}