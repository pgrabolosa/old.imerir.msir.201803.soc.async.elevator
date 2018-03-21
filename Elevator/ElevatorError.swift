public enum ElevatorError : Error {
    case cannotOperateUnderCurrentState
    case unreachableDestination
    case reachedMaxLoad
}
