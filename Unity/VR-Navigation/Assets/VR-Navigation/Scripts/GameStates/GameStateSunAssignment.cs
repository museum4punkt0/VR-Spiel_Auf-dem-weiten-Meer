using System;
using DG.Tweening;
using HumboldtForum.Timeline;
using HumboldtForum.VR;
using IJsfontein.Audio;
using IJsfontein.GameStates;
using UnityEngine.Playables;

namespace HumboldtForum.GameStates
{
    internal class GameStateSunAssignment : GameStateAssignment
    {
        public GameStateSunAssignment(GameContext gameContext) : base(gameContext, Main.LayerName.SunAssignment)
        {
        }

        public override void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            turtleTimeline.stopped += SkipBack;
            context.DayNightTimeline.Resume(); // set the sun
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
            if (Array.IndexOf(assignmentElements.CorrectButtons, b) > -1)
            {

                turtleTimeline.Seek(turtleTimeline.duration);
                context.SetAssignmentCompleted();

                DOVirtual.DelayedCall(2, () => PlayAudioFeedbackAndSailAway());
            }
        }

        private void PlayAudioFeedbackAndSailAway(int audioIndex = 0)
        {
            if (assignmentElements.CorrectAudio.Count > audioIndex)
            {
                AudioLibraryClipPlayer correctAudio = assignmentElements.CorrectAudio[audioIndex];
                if (correctAudio)
                {
                    correctAudio.Play(.5f);
                    correctAudio.Finished.AddListener(() =>
                    {
                        correctAudio.Finished.RemoveAllListeners();
                        PlayAudioFeedbackAndSailAway(audioIndex + 1);
                    }
                    );
                }
                else
                {
                    PlayAudioFeedbackAndSailAway(audioIndex + 1);
                }
            }
            else
            {
                StartSailingToNextAssignment();
            }
        }

        private void StartSailingToNextAssignment()
        {
            context.SetSailToAssignmentState(context.AssignmentIndex + 1, 1.5f);
        }
    }
}