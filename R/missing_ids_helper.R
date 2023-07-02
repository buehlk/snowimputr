#' Missing IDs Helper
#'
#' A helper function to identify missing IDs in a data frame.
#'
#' @param x The index of the channel ID in `id_stats`.
#' @param id_stats A data frame containing channel IDs and maximum IDs.
#' @param msg_df A data frame containing messages.
#' @param channel_ID The column name of the channel ID in `msg_df`.
#' @param message_ID The column name of the message ID in `msg_df`.
#' @return A data frame with missing channel IDs and their corresponding missing message IDs.
#' @import pbapply
#' @import data.table
#' @import dplyr
#' @importFrom  dplyr %>%
#' @import magrittr
#' @export
missing_ids_helper <- function(x, id_stats, msg_df, channel_ID, message_ID) {
  channel_id <- id_stats$channel_ID[x]
  all_ids <- 1:id_stats$maxID[which(id_stats$channel_ID == channel_id)]
  existing_ids <- msg_df %>%
    dplyr::filter(.data[[channel_ID]] == channel_id) %>%
    dplyr::select(all_of(message_ID)) %>%
    unlist()

  del_ids <- all_ids[which(all_ids %in% existing_ids == FALSE)]
  if (length(del_ids) > 0) {
    data.frame(Channel_ID = channel_id, Message_ID = del_ids)
  } else {
    data.frame(Channel_ID = character(), Message_ID = character())
  }
}
