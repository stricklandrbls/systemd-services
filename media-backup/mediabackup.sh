#!/bin/bash
TIME=$(date | awk '{print $2,$3,$4}')
tar -cf /mnt/backups/books.tar.xz -C /mnt/NAS --xz Books
tar -cf /mnt/backups/docs.tar.xz -C /mnt/NAS --xz Documents
tar -cf /mnt/backups/photos.tar.xz -C /mnt/NAS --xz Photos
echo "Completed backup at: "${TIME}
