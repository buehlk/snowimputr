#' Find Deleted Messages
#'
#' A function to find deleted messages based on the provided criteria.
#'
#' @param corpus_df A data frame containing the corpus of messages.
#' @param deleted_msg_ids A vector of deleted message IDs.
#' @param deleted_channel_ids A vector of deleted channel IDs.
#' @param fwd_from_colname The column name stating which channel a message was forwarded from in `corpus_df`.
#' @param fwd_msg_colname The column name stating the original message IDs of the forwareded message in `corpus_df`.
#' @param return_result The type of result to return (all, latest, oldest).
#' @param date_colname The column name of the date variable in `corpus_df`.
#' @param impute Logical value indicating whether to impute messages.
#' @param message_ID_colname The column name of the message ID (optional, required for impute).
#' @param channel_ID_colname The column name of the channel ID (optional, required for impute).
#' @return A data frame with the found deleted messages based on the specified criteria.
#' @examples
#' \dontrun{
#' telegram_data <- data.frame(
#' Channel_ID = rep(c("111111", "222222", "333333"), each = 6),
#' Message_ID = c(c(1:4, 6, 7), c(2:7), c(1, 5, 9, 15, 16, 19)),
#' Date = as.Date(c("2023-06-26", "2023-06-27", "2023-06-28", "2023-06-29", "2023-06-30", "2023-07-01",
#'                  "2023-06-27", "2023-06-28", "2023-06-29", "2023-06-29", "2023-06-30", "2023-07-01",
#'                  "2023-06-06", "2023-06-07", "2023-06-20", "2023-06-21", "2023-06-30", "2023-07-01"), format = "%Y-%m-%d"),
#' Forwarded_from_channel_ID = c(c("333333", "333333", "222222", rep(NA, 3)),
#'                               c(rep(NA, 4), "111111", "333333"), rep(NA, 6)),
#' Forwarded_from_message_ID = c(2, 3, 1, rep(NA, 7), 5, 2, rep(NA, 6)),
#' Message_content = c(
#'   c(rep("The original message is deleted, but available via bootstrap snowball imputation.", 3), rep("This is an organic message.", 3)),
#'   c(rep("This is an organic message.", 4), rep("The original message is deleted, but available via bootstrap snowball imputation."), 2),
#'   rep("This is an organic message.", 6)
#' )
#' )
#'
#' # Show all deleted messages in dataset:
#' deleted <- list_deleted_msg(msg_df = telegram_data,
#' channel_ID_colname = "Channel_ID",
#' message_ID_colname = "Message_ID")
#'
#' # Show the deleted messages of Channel "333333"
#' deleted <- list_deleted_msg(msg_df = telegram_data,
#' channel_ID_colname = "Channel_ID",
#' message_ID_colname = "Message_ID",
#' target_entity = "333333")
#'
#' @import pbapply
#' @import data.table
#' @import dplyr
#' @import magrittr
#' @importFrom  dplyr %>%
#' @export
find_deleted_msg <- function(corpus_df, deleted_msg_ids, deleted_channel_ids,
                             fwd_from_colname, fwd_msg_colname,
                             return_result = "all", date_colname = NA,
                             impute = FALSE, message_ID_colname = NA,
                             channel_ID_colname = NA) {

  if (is.na(date_colname) & return_result != "all") {
    stop("\nError: No date variable in the corpus specified!\n\n")
  }
  if (impute & any(is.na(message_ID_colname) | is.na(channel_ID_colname))) {
    stop("\nError: To impute messages, you need to specify the names of the message ID and the channel ID column!\n\n")
  }

  unique_id <- paste(deleted_channel_ids, deleted_msg_ids, sep = "_")

  old_list <- corpus_df %>%
    dplyr::mutate(PK_REFERENCE = paste(.data[[fwd_from_colname]], .data[[fwd_msg_colname]], sep = "_")) %>%
    dplyr::filter(PK_REFERENCE != "_NA") %>%
    data.table::data.table()

  setkey(old_list, "PK_REFERENCE")

  found <- pbapply::pblapply(unique_id, function(x) old_list[.(x), nomatch = 0L]) %>%
    do.call("rbind", .)

  if (impute) {
    found <- found %>%
      dplyr::mutate(
        {{message_ID_colname}} := .data[[fwd_msg_colname]],
        {{channel_ID_colname}} := .data[[fwd_from_colname]],
        {{fwd_from_colname}} := NA,
        {{fwd_msg_colname}} := NA
      )
  }

  if (return_result == "all") {
    return(found %>%
             dplyr::select(!PK_REFERENCE))
  }
  if (return_result == "latest") {
    return(found %>%
             dplyr::arrange(dplyr::desc(as.Date(.data[[date_colname]]))) %>%
             dplyr::distinct(PK_REFERENCE, .keep_all = TRUE) %>%
             dplyr::select(!PK_REFERENCE)
    )
  }

  if (return_result == "oldest") {
    return(found %>%
             dplyr::arrange(as.Date(.data[[date_colname]])) %>%
             dplyr::distinct(PK_REFERENCE, .keep_all = TRUE) %>%
             dplyr::select(!PK_REFERENCE)
    )
  }

  # Return an empty data frame if return_result is not valid
  return(data.frame())

}
