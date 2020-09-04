using System.Collections.Generic;
using DG.Tweening;
using HumboldtForum.Controls;
using HumboldtForum.Timeline;
using IJsfontein.Audio;
using IJsfontein.GameStates;
using IJsfontein.LayerElements;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.Playables;
using UnityEngine.SceneManagement;
using Valve.VR;

namespace HumboldtForum.GameStates
{
    public class GameContext : IGameContext
    {
        public ElementsLayerSwitcher LayerSwitcher => layerSwitcher;
        public GameStateMachine StateMachine => stateMachine;
        public int AssignmentIndex => assignmentIndex;
        public int CompletedAssignments => completedAssignments;

        public Boat Boat { get; internal set; }
        public PlayableDirector DayNightTimeline { get; internal set; }
        public AudioLibraryClipPlayer TurtleAudioPlayer { get; internal set; }
        public AudioMixer AudioMixer { get; internal set; }
        public Settings Settings { get; internal set; }

        private readonly ElementsLayerSwitcher layerSwitcher;
        private readonly GameStateMachine stateMachine;

        private PlayableDirector achievementsTimeline;
        private int assignmentIndex = -1;
        private int completedAssignments = 0;
        private Tween timeout;

        public GameContext(ElementsLayerSwitcher layerSwitcher, GameStateMachine stateMachine)
        {
            this.layerSwitcher = layerSwitcher;
            this.stateMachine = stateMachine;
        }

        internal void SetAchievementsTimeline(PlayableDirector value)
        {
            achievementsTimeline = value;
        }

        internal void SetSailToAssignmentState(int newIndex, float speed)
        {
            Boat.Speed = speed;
            SetSailToAssignmentState(newIndex);
        }

        internal void SetSailToAssignmentState(int newIndex)
        {
            assignmentIndex = newIndex;
            GameState value = default;
            switch (assignmentIndex)
            {
                case 0:
                    {
                        value = new GameStateSailToAssignment(this, Main.LayerName.Start);
                        break;
                    }
                case 1:
                    {
                        value = new GameStateSailToAssignment(this, Main.LayerName.SailWest);
                        break;
                    }
                case 2:
                    {
                        value = new GameStateSailToAssignment(this, Main.LayerName.SailSouth);
                        break;
                    }
                case 3:
                    {
                        value = new GameStateSailToAssignment(this, Main.LayerName.SailToBirds);
                        break;
                    }
                case 4:
                    {
                        value = new GameStateSailToAssignment(this, Main.LayerName.SailToIsland);
                        break;
                    }
            }
            if (value != default(GameState))
            {
                stateMachine.SetState(value);
            }
        }

        public void StopGameTimer()
        {
            if (timeout != default)
            {
                Debug.Log($"{this}: killing game time out");
                timeout.Kill();
                timeout = default;
            }
        }

        public void StartGameTimer()
        {
            StopGameTimer();
            Debug.Log($"{this}: game time out in {Settings.GameDurationSeconds} seconds");
            timeout = DOVirtual.DelayedCall(Settings.GameDurationSeconds, TriggerTimeout);
        }

        internal void TriggerTimeout()
        {
            StopGameTimer();
            Debug.Log($"{this} triggered game time out");
            float fadeDuration = .3f;
            float holdBlack = 2f;
            SteamVR_Fade.Start(Color.black, fadeDuration);

            DOVirtual.DelayedCall(fadeDuration, () =>
            {
                StateMachine.SetState(new GameStateParty(this, true));
                Dictionary<string, LabelMarker> labels = DayNightTimeline.LabelMarkerTimes();
                DayNightTimeline.Seek(labels["Finish"]);
                DOVirtual.DelayedCall(holdBlack, () =>
                {
                    SteamVR_Fade.Start(Color.clear, fadeDuration);
                });
            });
        }

        public void LoadLanguageSelection(float holdBlack, float fadeDuration)
        {
            StopGameTimer();
            SteamVR_Fade.Start(Color.black, fadeDuration);

            DOVirtual.DelayedCall(holdBlack + fadeDuration, () =>
            {
                stateMachine.SetState(null);
                SceneManager.LoadSceneAsync("Intro");
            });
        }

        internal void SetAssignmentCompleted()
        {
            completedAssignments++;
            Debug.Log($"{this}: {completedAssignments} assignments completed");
            AdvanceAchievementTimeline();
        }

        public void AdvanceAchievementTimeline()
        {
            achievementsTimeline.Resume();
        }

        internal void SetAssignmentState()
        {
            SetAssignmentState(assignmentIndex);
        }

        internal void SetAssignmentState(int newIndex)
        {
            assignmentIndex = newIndex;
            GameState value = default;
            switch (assignmentIndex)
            {
                case 0:
                    {
                        value = new GameStateSunAssignment(this);
                        break;
                    }
                case 1:
                    {
                        value = new GameStateStarsAssignment(this);
                        break;
                    }
                case 2:
                    {
                        value = new GameStateCloudsAssignment(this);
                        break;
                    }
                case 3:
                    {
                        value = new GameStateBirdsAssignment(this);
                        break;
                    }
                case 4:
                    {
                        value = new GameStateParty(this, false);
                        break;
                    }
            }
            if (value != default(GameState))
            {
                stateMachine.SetState(value);
            }
        }
    }
}