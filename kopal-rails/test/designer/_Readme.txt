A highly simple replacement for Fixtures. Just plain ruby code and plain old way
of creating table rows! i.e., using ModelName.new !

TODO:
Create a Rails plugin which - 
# makes a task - rake desginer:create
# makes available records using a variable like @user_account[:hello]. Think of some mechanism. Or let users define instance variables right in desginer file, like I do today.

Advantage -
1. Highly Simple.
2. Data passes through all the validations defined in models.
    
    
Note - 
Rows specific to a test should be written with that test only. Only rows which needs
to be present in database irrespective of test or for multiplt tests should be created in Designer.

Number the designer files in the order they should be executed. For example 
UserAccount model should be executed first to get UserIdentity right.

Also designer files need not be a file per class, they all may be in one file.
Files can also be separated using a task per file. All record saving for a particular
test can be in one file. 

