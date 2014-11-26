## Merge Twitter Database Spreadsheets
dataset1 <- read.csv("AllJ363JTwitterFollowers1.csv")
dataset2 <- read.csv("AllJ363JTwitterFollowers2.csv")
names(dataset1)
names(dataset2)
fix(dataset1)
str(dataset2)
merged.data <- merge(dataset1, dataset2, by="Display.Name")
fix(merged.data)
merged.twitterdata.all <- merge(dataset1, dataset2, by="Display.Name", all=TRUE)
fix(merged.data.all)
write.csv(merged.twitterdata.all, file = "AllTwitterFollowers1.csv")
## End Merge Twitter Database Spreadsheets

## Merge Company List Spreadsheets
dataset3 <- read.csv("CompanyListSpreadsheet1.csv")
dataset4 <- read.csv("CompanyListSpreadsheet2.csv")
names(dataset3)
names(dataset4)
fix(dataset3)
str(dataset4)
merged.companydata.all <- merge(dataset3, dataset4, by.x="Organization.Name", by.y="Company.Name", all=TRUE)
str(merged.companydata.all)
fix(merged.companydata.all)
write.csv(merged.companydata.all, file = "AllCompanyContacts1.csv")
## End Merge Company List Spreadsheets
