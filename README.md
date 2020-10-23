# With Transaction

This small tool decorates existing command(s) that work on a single text file (and assume unfettered access) with protections for concurrent accesses via file locking of a separate lock file, thereby providing support for simple transactions, with multiple concurrent reads, a singular write (and a command to update from read to write), and rollback of any updates done under the transaction.

## Dependencies

* Bash
* `flock` for transaction support
* automated testing is done with _bats - Bash Automated Testing System_ (https://github.com/bats-core/bats-core)
