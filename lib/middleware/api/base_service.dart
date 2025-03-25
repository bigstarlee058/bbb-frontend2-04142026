abstract class BaseService<T> {
  static const fetchExerciseHistory = "/api/exercise-history/fetch";
  static const addExerciseHistory = "/api/exercise-history/add";
  static const updateExerciseHistory = "/api/exercise-history/update";

  static const fetchExerciseStatus = "/api/exercise-status/fetch";
  static const addExerciseStatus = "/api/exercise-status/add";
  static const updateExerciseStatus = "/api/exercise-status/update";

  static const fetchDayStatus = "/api/day-status/fetch";
  static const addDayStatus = "/api/day-status/add";
  static const updateDayStatus = "/api/day-status/update";

  static const fetchExtraSet = "/api/extra-set/fetch";
  static const addExtraSet = "/api/extra-set/add";

  static const fetchExerciseNotes = "/api/exercise-notes/fetch";
  static const addExerciseNotes = "/api/exercise-notes/add";

  static const fetchRemovedExercise = "/api/remove-exercise/fetch";
  static const addRemovedExercise = "/api/remove-exercise/add";
  static const deleteRemovedExercise = "/api/remove-exercise/delete";

  static const fetchExtraExercise = "/api/extra-exercise/fetch";
  static const addExtraExercise = "/api/extra-exercise/add";
  static const deleteExtraExercise = "/api/extra-exercise/delete";

  static const fetchSwapExercise = "/api/swap-exercise/fetch";
  static const addSwapExercise = "/api/swap-exercise/add";
  static const deleteSwapExercise = "/api/swap-exercise/delete";

  static const updateStreakCount = "/api/streak-count/update";
  static const fetchStreakCount = "/api/streak-count/fetch";

  static const addDayStatusList = "/api/day-status-list/add";
  static const fetchDayStatusList = "/api/day-status-list/fetch";
}
