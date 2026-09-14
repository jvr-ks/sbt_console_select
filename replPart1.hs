val wd = os.pwd / "_toGitHub" /** delay=3000 */
val gitStatus = os.proc("git", "status").call(wd)

