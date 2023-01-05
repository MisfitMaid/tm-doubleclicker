<?php

echo sprintf('string executableChecksum = "%s";', hash_file("sha256", "Doubleclicker.exe"));