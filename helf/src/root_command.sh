# HAS_ALLOW_UNSAFE='y' has bat || echo "need bat" && exit 1

command "${args[program]}" "--help" | bat --paging always
