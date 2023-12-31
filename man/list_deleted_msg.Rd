% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list_deleted_msg.R
\name{list_deleted_msg}
\alias{list_deleted_msg}
\title{List Deleted Messages}
\usage{
list_deleted_msg(
  msg_df,
  channel_ID_colname,
  message_ID_colname,
  target_entity = ""
)
}
\arguments{
\item{msg_df}{A data frame containing Telegram messages.}

\item{channel_ID_colname}{The column name of the channel ID in `msg_df`.}

\item{message_ID_colname}{The column name of the message ID in `msg_df`.}

\item{target_entity}{Channel ID of channel for which deleted messages should be searched. (optional). If none is chosen, all deleted messages in the dataset are searched.}
}
\value{
A data frame with deleted channel IDs and their corresponding deleted message IDs.
}
\description{
A function to list deleted messages based on the provided criteria.
}
\examples{
\dontrun{
telegram_data <- data.frame(
Channel_ID = rep(c("111111", "222222", "333333"), each = 6),
Message_ID = c(c(1:4, 6, 7), c(2:7), c(1, 5, 9, 15, 16, 19)),
Date = as.Date(c("2023-06-26", "2023-06-27", "2023-06-28", "2023-06-29", "2023-06-30", "2023-07-01",
                 "2023-06-27", "2023-06-28", "2023-06-29", "2023-06-29", "2023-06-30", "2023-07-01",
                 "2023-06-06", "2023-06-07", "2023-06-20", "2023-06-21", "2023-06-30", "2023-07-01"), format = "\%Y-\%m-\%d"),
Forwarded_from_channel_ID = c(c("333333", "333333", "222222", rep(NA, 3)),
                              c(rep(NA, 4), "111111", "333333"), rep(NA, 6)),
Forwarded_from_message_ID = c(2, 3, 1, rep(NA, 7), 5, 2, rep(NA, 6)),
Message_content = c(
  c(rep("The original message is deleted, but available via bootstrap snowball imputation.", 3), rep("This is an organic message.", 3)),
  c(rep("This is an organic message.", 4), rep("The original message is deleted, but available via bootstrap snowball imputation.", 2)),
  rep("This is an organic message.", 6)
)
)

# Show the deleted messages of Channel "333333"
deleted <- list_deleted_msg(msg_df = telegram_data,
channel_ID_colname = "Channel_ID",
message_ID_colname = "Message_ID",
target_entity = "333333")
}
}
