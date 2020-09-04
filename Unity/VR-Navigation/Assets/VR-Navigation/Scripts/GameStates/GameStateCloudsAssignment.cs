using System;
using HumboldtForum.Timeline;
using HumboldtForum.VR;
using IJsfontein.Audio;
using IJsfontein.GameStates;
using UnityEngine;
using UnityEngine.Playables;

namespace HumboldtForum.GameStates
{
    internal class GameStateCloudsAssignment : GameStateAssignment
    {

        public GameStateCloudsAssignment(GameContext gameContext) : base(gameContext, Main.LayerName.CloudsAssignment)
        {
        }

        public override void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            context.DayNightTimeline.Resume();// make it turn day again
            turtleTimeline.stopped += SkipBack;
            context.Boat.SetDrift(-.125f);
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
            if (Array.IndexOf(assignmentElements.CorrectButtons, b) > -1)
            {
                Debug.Log($"{this}: gazed at correct cloud {b}", b);
                HideAllGazeButtons();

                AudioLibraryClipPlayer correctAudio = default;

                if (assignmentElements.CorrectAudio.Count > 0)
                {
                    correctAudio = assignmentElements.CorrectAudio[0];
                    if (correctAudio)
                    {
                        turtleTimeline.Stop();
                        turtleTimeline.Seek(turtleTimeline.duration);

                        correctAudio.Play();
                        correctAudio.Finished.AddListener(() =>
                        {
                            correctAudio.Finished.RemoveAllListeners();
                            Next();
                        }
                        );
                    }
                    else
                    {
                        Next();
                    }
                }
            }
            else if (b.name.Contains("Wrong"))
            {
                if (assignmentElements.IncorrectAudio)
                {
                    SkipTurtle();
                    assignmentElements.IncorrectAudio.Play();
                    Debug.Log($"{this}: gazed at wrong cloud", b);
                }
            }
        }

        private void Next()
        {
            context.SetAssignmentCompleted();
            context.SetSailToAssignmentState(context.AssignmentIndex + 1, 1.5f);
        }
    }
}