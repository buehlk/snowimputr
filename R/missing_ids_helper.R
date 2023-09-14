#' Missing IDs Helper
#'
#' A helper function to identify missing IDs in a data frame.
#'
#' @param x The index of the channel ID in `id_stats`.
#' @param id_stats A data frame containing channel IDs and maximum IDs.
#' @param msg_df A data frame containing messages.
#' @param channel_ID The column name of the channel ID in `msg_df`.
#' @param message_ID The column name of the message ID in `msg_df`.
#' @param truncated This option should be chosen in case only a part of the channels' message history was scraped.If FALSE, the first message ID is assumed to be 1, if TRUE the minimum message ID constitutes the first message. Default: FALSE. 
#' @return A data frame with missing channel IDs and their corresponding missing message IDs.
#' @import pbapply
#' @import data.table
#' @import dplyr
#' @import tibble
#' @importFrom  dplyr %>%
#' @import magrittr
#' @export
missing_ids_helper <- function (x, id_stats, msg_df, channel_ID, message_ID, truncated) 
{
  if (truncated == FALSE) {
    id_stats$minID <- 1
  }
  channel_id <- id_stats$channel_ID[x]
  all_ids <- id_stats$minID[which(id_stats$channel_ID == channel_id)]:id_stats$maxID[which(id_stats$channel_ID == 
                                                                                             channel_id)]
  existing_rows <- msg_df[,get(channel_ID)] %>% 
    data.frame() %>% 
    dplyr::rename(channel_id_col = ".") %>% 
    tibble::rownames_to_column() %>% 
    mutate(rowname = as.numeric(rowname)) %>% 
    dplyr::filter(channel_id_col == channel_id) %>% 
    select(rowname) %>% 
    unlist() %>% 
    unname()
  
  
  existing_ids <- msg_df[existing_rows, get(message_ID)] %>% 
    as.numeric()
  
  del_ids <- all_ids[which(all_ids %in% existing_ids == FALSE)]
  if (length(del_ids) > 0) {
    data.frame(Channel_ID = channel_id, Message_ID = del_ids)
  }
  else {
    data.frame(Channel_ID = character(), Message_ID = character())
  }
}