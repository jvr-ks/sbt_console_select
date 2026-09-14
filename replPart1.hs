val wd = os.pwd / "_toGitHub" 
val gitStatus = os.proc("git", "status").call(wd)



