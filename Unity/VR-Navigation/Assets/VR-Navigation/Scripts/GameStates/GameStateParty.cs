using System;
using System.Collections.Generic;
using DG.Tweening;
using HumboldtForum.Timeline;
using IJsfontein.Audio;
using IJsfontein.GameStates;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.Playables;
using Valve.VR;

namespace HumboldtForum.GameStates
{
    internal class GameStateParty : GameState
    {
        private readonly TrackMuter partyAnimation;
        private Tween timeOut;

        public GameStateParty(GameContext gameContext, bool isTooLate) : base(gameContext, Main.LayerName.PartyIsland)
        {
            bool notAllAssignmentsCompleted = context.CompletedAssignments < 4;
            partyAnimation = GetComponentForLayer<TrackMuter>();
            float delay = .2f;
            if (isTooLate && notAllAssignmentsCompleted)
            {
                delay = 2.5f;
            }

            partyAnimation.gameObject.SetActive(true);

            if (notAllAssignmentsCompleted || isTooLate)
            {
                Transform targetTransform = GetComponentForLayer<Transform>("End Timeline");
                // teleport us to the end location
                context.Boat.transform.position = targetTransform.position;
                context.Boat.transform.rotation = targetTransform.rotation;
                context.Boat.NoGoWarning.gameObject.SetActive(false);
                context.Boat.StopSailing(true);
            }

            PlayableDirector anim = partyAnimation.GetComponent<PlayableDirector>();
            DOVirtual.DelayedCall(delay, anim.Play);

        }

        override public void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            context.Boat.StopSailing();
            context.Boat.SetDrift(0);
            context.StopGameTimer();
            context.DayNightTimeline.Resume(); // set the sun

            partyAnimation.MuteTracks(context.CompletedAssignments);
            
            StartTimeOut();
        }

        override public void Deactivate(AbstractGameState nextState)
        {
            StopTimeOut();
            base.Deactivate(nextState);
        }

        private void StartTimeOut()
        {
            StopTimeOut();
            Debug.Log($"{this}: end screen time out in {context.Settings.EndScreenDurationSeconds} seconds");
            timeOut = DOVirtual.DelayedCall(context.Settings.EndScreenDurationSeconds, FadeOut);
        }

        private void FadeOut()
        {
            Debug.Log($"{this} triggered end screen time out");
            SteamVR_Fade.Start(Color.black, 1);
            context.AudioMixer.FindSnapshot("Off").TransitionTo(1);
        }

        private void StopTimeOut()
        {
            if (timeOut != null)
            {
                Debug.Log($"{this}: killing end screen time out");
                timeOut.Kill();
                timeOut = null;
            }
        }
    }
}