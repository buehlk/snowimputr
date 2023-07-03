#' List Deleted Messages
#'
#' A function to list deleted messages based on the provided criteria.
#'
#' @param msg_df A data frame containing Telegram messages.
#' @param channel_ID_colname The column name of the channel ID in `msg_df`.
#' @param message_ID_colname The column name of the message ID in `msg_df`.
#' @param target_entity Channel ID of channel for which deleted messages should be searched. (optional). If none is chosen, all deleted messages in the dataset are searched.
#' @return A data frame with deleted channel IDs and their corresponding deleted message IDs.
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
#' # Show the deleted messages of Channel "333333"
#' deleted <- list_deleted_msg(msg_df = telegram_data,
#' channel_ID_colname = "Channel_ID",
#' message_ID_colname = "Message_ID",
#' target_entity = "333333")
#'
#' # Find the messages in the dataset that were deleted in "333333" but forwarded in other channels
#' find_deleted_msg(
#' corpus_df = telegram_data,
#' deleted_msg_ids = deleted$Message_ID,
#' deleted_channel_ids = deleted$Channel_ID,
#' fwd_from_colname = "Forwarded_from_channel_ID",
#' fwd_msg_colname = "Forwarded_from_message_ID"
#' )
#'
#' # In case the same message is found several times show only the oldest
#' find_deleted_msg(
#' corpus_df = telegram_data,
#' deleted_msg_ids = deleted$Message_ID,
#' deleted_channel_ids = deleted$Channel_ID,
#' fwd_from_colname = "Forwarded_from_channel_ID",
#' fwd_msg_colname = "Forwarded_from_message_ID",
#' date_colname = "Date", return_result = "oldest"
#' )
#'
#' # Show only the oldest and conveniently impute the original channel ID and message ID
#' find_deleted_msg(
#' corpus_df = telegram_data,
#' deleted_msg_ids = deleted$Message_ID,
#' deleted_channel_ids = deleted$Channel_ID,
#' fwd_from_colname = "Forwarded_from_channel_ID",
#' fwd_msg_colname = "Forwarded_from_message_ID",
#' date_colname = "Date", return_result = "oldest",
#' message_ID_colname = "Message_ID",
#' channel_ID_colname = "Channel_ID",
#' impute = TRUE
#' )
#' @rdname list_deleted_msg
#' @export
#' @import pbapply
#' @import data.table
#' @import dplyr
#' @import magrittr
#' @importFrom  dplyr %>%

list_deleted_msg <- function(msg_df, channel_ID_colname, message_ID_colname, target_entity = "") {
  messageID_stats <- msg_df %>%
    dplyr::filter(
      dplyr::case_when(
        .data[[channel_ID_colname]] == target_entity ~ nchar(target_entity) > 0,
        TRUE ~ nchar(target_entity) == 0
      )
    ) %>%
    dplyr::group_by(.data[[channel_ID_colname]]) %>%
    dplyr::summarize(
      minID = min(.data[[message_ID_colname]]),
      maxID = max(.data[[message_ID_colname]])
    ) %>%
    dplyr::rename(channel_ID = .data[[channel_ID_colname]])

  lapply(1:length(messageID_stats$channel_ID), missing_ids_helper,
         id_stats = messageID_stats, msg_df = msg_df,
         message_ID = message_ID_colname, channel_ID = channel_ID_colname) %>%
    do.call(rbind, .)
}
