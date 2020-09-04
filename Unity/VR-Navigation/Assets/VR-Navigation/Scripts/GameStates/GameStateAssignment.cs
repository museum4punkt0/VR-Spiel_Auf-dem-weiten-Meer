using System.Collections.Generic;
using HumboldtForum.Assignments;
using HumboldtForum.Timeline;
using HumboldtForum.VR;
using IJsfontein.GameStates;
using UnityEngine;
using UnityEngine.Playables;

namespace HumboldtForum.GameStates
{
    internal abstract class GameStateAssignment : GameState
    {
        protected readonly GazeButton[] buttons;
        protected readonly AssignmentElements assignmentElements;
        protected readonly PlayableDirector turtleTimeline;
        protected readonly PlayableDirector poemTimeline;
        protected readonly Dictionary<string, LabelMarker> turtleMarkers;
        public GameStateAssignment(GameContext context, Main.LayerName layer) : base(context, layer)
        {
            buttons = GetComponentsForLayer<GazeButton>();
            assignmentElements = GetComponentForLayer<AssignmentElements>();
            turtleTimeline = assignmentElements.TurtleTimeline;
            poemTimeline = assignmentElements.PoemTimeline;
            turtleMarkers = turtleTimeline.LabelMarkerTimes();
        }

        override public void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            context.Boat.StopSailing();

            foreach (GazeButton b in buttons)
            {
                AddListenerToButton(b);
            }
            EnableAllGazeButtons(false);

            poemTimeline.paused += OnPoemFinished;

        }

        override public void Deactivate(AbstractGameState nextState)
        {
            foreach (GazeButton b in buttons)
            {
                b.OnSelected.RemoveAllListeners();
            }
            EnableAllGazeButtons(false);
            poemTimeline.paused -= OnPoemFinished;

            base.Deactivate(nextState);
        }

        protected virtual void OnPoemFinished(PlayableDirector t)
        {
            Debug.Log($"{this} OnPoemFinished at {t.time}");
            if (t.time >= t.duration - 1) // only if we are really at the end, not paused near beginning
            {
                EnableAllGazeButtons();
            }
        }

        protected void AddListenerToButton(GazeButton b)
        {
            b.OnSelected.AddListener(() =>
            {
                OnButtonSelected(b);
            });
        }

        protected void HideAllGazeButtons()
        {
            foreach (GazeButton b in buttons)
            {
                b.gameObject.SetActive(false);
            }
        }

        protected void EnableAllGazeButtons(bool enabled = true)
        {
            foreach (GazeButton b in buttons)
            {
                // Debug.Log($"{this}: setting enabled of {b} to {enabled}", b);
                b.enabled = enabled;
            }
        }

        protected abstract void OnButtonSelected(GazeButton b);

        /// <summary>
        ///  skip to next marker if playing
        /// </summary>
        protected void SkipTurtle()
        {
            if (turtleTimeline.state == PlayState.Playing)
            {
                turtleTimeline.SkipToNextMarker();
            }
        }
    }
}