abstract class BaseService<T> {
  static const fetchExerciseHistory = "exercise-history/fetch";
  static const addExerciseHistory = "exercise-history/add";
  static const updateExerciseHistory = "exercise-history/update";

  static const fetchExerciseStatus = "exercise-status/fetch";
  static const addExerciseStatus = "exercise-status/add";
  static const updateExerciseStatus = "exercise-status/update";

  static const fetchDayStatus = "day-status/fetch";
  static const addDayStatus = "day-status/add";
  static const updateDayStatus = "day-status/update";

  static const fetchExtraSet = "extra-set/fetch";
  static const addExtraSet = "extra-set/add";

  static const fetchExerciseNotes = "exercise-notes/fetch";
  static const addExerciseNotes = "exercise-notes/add";

  static const fetchRemovedExercise = "remove-exercise/fetch";
  static const addRemovedExercise = "remove-exercise/add";
  static const deleteRemovedExercise = "remove-exercise/delete";

  static const fetchExtraExercise = "extra-exercise/fetch";
  static const addExtraExercise = "extra-exercise/add";
  static const deleteExtraExercise = "extra-exercise/delete";

  static const fetchSwapExercise = "swap-exercise/fetch";
  static const addSwapExercise = "swap-exercise/add";
  static const deleteSwapExercise = "swap-exercise/delete";
}
