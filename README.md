# COMPSYS_305_Mini_Project
How to use GitHub for this project:

Branch tree:
        (work here)
mimi ───────────────┐
emma ────────────────┼──→  main (ONLY tested code)
teammate3 ───────────┘

Daily workflow:
Before doing anything       git checkout main
                            git pull origin main
                            git checkout your-branch-name
                            
Make changes on your own branch
                            git add .
                            git commit -m "describe feature"
                            git push
                          
Keep syncing with main (when there is a new version of main)
                          git checkout your-branch
                          git merge main
