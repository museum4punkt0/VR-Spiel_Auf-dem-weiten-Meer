using System;
using System.Collections.Generic;
using DG.Tweening;
using HumboldtForum.Timeline;
using IJsfontein.GameStates;
using UnityEngine;
using UnityEngine.Playables;

namespace HumboldtForum.GameStates
{
    public class GameStateTurtleIntro : GameState
    {
        private readonly PlayableDirector turtleTimeline;
        private readonly Dictionary<string, LabelMarker> turtleMarkers;
        private bool turtleActivated = false;
        private bool startedSailing = false;

        public GameStateTurtleIntro(GameContext context) : base(context, Main.LayerName.TurtleIntro)
        {
            turtleTimeline = GetComponentForLayer<PlayableDirector>("TurtleIntroTimelineDirector");
            turtleMarkers = turtleTimeline.LabelMarkerTimes();
            turtleActivated = false;
        }

        override public void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            turtleTimeline.Play();
            turtleTimeline.paused += OnPaused;
            context.Boat.Speed = .5f; // start a little slower
        }

        override public void Deactivate(AbstractGameState nextState)
        {
            context.Boat.StartSteering.RemoveListener(context.Boat.StartSailing);
            context.Boat.StopSteering.RemoveListener(context.Boat.StopSailing);
            turtleTimeline.paused -= OnPaused;
            turtleTimeline.stopped += OnTurtleStopped;
            base.Deactivate(nextState);
        }

        private void OnTurtleStopped(PlayableDirector timeline)
        {
            timeline.stopped -= OnTurtleStopped;
            Debug.Log($"{this} turtle has stopped");
            timeline.gameObject.SetActive(false);
        }

        private void OnPaused(PlayableDirector playableDirector)
        {
            if (turtleActivated)
            {
                Debug.Log($"{this}: check paddle {context.Boat.IsPaddleEnabled}");
                context.Boat.StartSteering.RemoveListener(StartSailing);
                if (context.Boat.IsPaddleEnabled)
                {
                    StartSailing();
                }
                else
                {
                    playableDirector.Seek(turtleMarkers["Bad"]);
                    context.Boat.StartSteering.AddListener(StartSailing);
                }
                playableDirector.Resume();
            }
            else
            {
                turtleActivated = true; // first time paused is at activation gaze button.
                playableDirector.Seek(turtleMarkers["SkipIntro"]);
            }
        }

        private void StartSailing()
        {
            if (!startedSailing)
            {
                // Debug.Log($"{this}: that's good");
                context.Boat.StartSteering.RemoveListener(StartSailing);
                turtleTimeline.Seek(turtleMarkers["Good"]);

                context.AdvanceAchievementTimeline();
                DOVirtual.DelayedCall(15, Next);
                context.Boat.StartSailing();

                context.Boat.StartSteering.AddListener(context.Boat.StartSailing);
                context.Boat.StopSteering.AddListener(context.Boat.StopSailing);

                startedSailing = true;
            }
        }

        private void StartTurtle(PlayableDirector obj)
        {
            turtleTimeline.Play();
        }

        private void Next()
        {
            Debug.Log($"{this}: start sailing {context.Boat.Speed}");
            context.Boat.SetDrift(-.125f);
            context.SetSailToAssignmentState(context.AssignmentIndex + 1);
            if (turtleTimeline.state != PlayState.Playing)
            {
                turtleTimeline.Resume();
            }
        }
    }
}