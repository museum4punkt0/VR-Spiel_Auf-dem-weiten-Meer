using System;
using HumboldtForum.Timeline;
using HumboldtForum.Transforms;
using HumboldtForum.VR;
using IJsfontein.Audio;
using IJsfontein.GameStates;
using UnityEngine;
using UnityEngine.Playables;

namespace HumboldtForum.GameStates
{
    internal class GameStateBirdsAssignment : GameStateAssignment
    {
        private readonly TransformChildrenChangeNotifier[] birdFlocks;
        private bool done = false;

        public GameStateBirdsAssignment(GameContext gameContext) : base(gameContext, Main.LayerName.BirdsAssignment)
        {
            birdFlocks = GetComponentsForLayer<TransformChildrenChangeNotifier>();
        }

        public override void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            context.DayNightTimeline.Resume(); // sun
            turtleTimeline.stopped += SkipBack;
            foreach (var flock in birdFlocks)
            {
                flock.OnAdded.AddListener(OnBirdAdded);
                flock.OnDeleted.AddListener(OnBirdDeleted);
            }
            SetAllBirdsGazeButtons(true);
            context.Boat.SetDrift(.125f);
        }

        public override void Deactivate(AbstractGameState nextState)
        {
            foreach (var flock in birdFlocks)
            {
                flock.OnAdded.RemoveListener(OnBirdAdded);
                flock.OnDeleted.RemoveListener(OnBirdDeleted);
            }
            SetAllBirdsGazeButtons(false);
            turtleTimeline.stopped -= SkipBack;
            base.Deactivate(nextState);
        }

        private void SkipBack(PlayableDirector d)
        {
            d.Seek(turtleMarkers["Last"]);
        }

        private void OnBirdAdded(Transform t)
        {
            GazeButton b = t.GetComponentInChildren<GazeButton>(includeInactive: true);
            if (b)
            {
                AddListenerToButton(b);
                b.gameObject.SetActive(!done);
            }
        }

        private void OnBirdDeleted(Transform t)
        {
            GazeButton b = t.GetComponentInChildren<GazeButton>();
            if (b)
            {
                b.OnSelected.RemoveAllListeners();
            }
        }

        protected override void OnButtonSelected(GazeButton b)
        {
            // Debug.Log($"{this}: gaze button triggered {b.name}");
            if (b.name.Contains("Wrong"))// found a wrong one, but don't want this sound when activating the turtle!
            {
                SkipTurtle();
                assignmentElements.IncorrectAudio?.Play();
            }
            else if (b.name.Contains("Correct"))
            {
                AudioLibraryClipPlayer correctAudio = default;

                done = true; // birds that are spawned now will not be enabled
                SetAllBirdsGazeButtons(false);

                turtleTimeline.Stop();
                turtleTimeline.Seek(turtleTimeline.duration);

                if (assignmentElements.CorrectAudio.Count > 0)
                {
                    correctAudio = assignmentElements.CorrectAudio[0];
                    if (correctAudio)
                    {
                        correctAudio.Play();
                        correctAudio.Finished.AddListener(() =>
                        {
                            correctAudio.Finished.RemoveAllListeners();
                            Next();
                        }
                        );
                    }
                }
                else
                {
                    Next();
                }
            }
        }

        private void Next()
        {
            context.SetAssignmentCompleted();
            context.SetSailToAssignmentState(context.AssignmentIndex + 1, 1.5f);
        }

        private void SetAllBirdsGazeButtons(bool enabled)
        {
            foreach (var flock in birdFlocks)
            {
                GazeButton[] buttons = flock.GetComponentsInChildren<GazeButton>(includeInactive: true);
                foreach (GazeButton b in buttons)
                {
                    b.gameObject.SetActive(enabled);
                }
            }
        }
    }
}