using IJsfontein.LayerElements;

namespace IJsfontein.GameStates
{
    public interface IGameContext
    {
        ElementsLayerSwitcher LayerSwitcher { get; }
        GameStateMachine StateMachine { get; }
    }

}
