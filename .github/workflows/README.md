# Automated Review Labels

These diagrams explain the workflow of the automated review labels actions.

## Workflow

```mermaid
sequenceDiagram
    actor User
    participant issue
    participant GitHub actions
    actor Authenticated bot
    actor Reviewer
    Note right of Authenticated bot: Authenticated bot is a GitHub action with the necessary rights for getMembershipForUserInOrg
    User->>issue: Adds any comment
    activate GitHub actions
    alt is PR AND no review-requested label exists
        loop Over ['@conda-forge/staged-recipes', '@conda-forge/help-python', '@conda-forge/help-python-c', '@conda-forge/help-r', '@conda-forge/help-java', '@conda-forge/help-nodejs', '@conda-forge/help-c-cpp', '@conda-forge/help-perl', '@conda-forge/help-julia', '@conda-forge/help-ruby']
            alt team is in comment
                GitHub actions->>issue: Adds review-requested label
                GitHub actions->>issue: Adds team label
                GitHub actions->>issue: Remove Awaiting author contribution label
                rect rgb(191, 223, 255)
                    GitHub actions-->>issue: Assigns team for review
                end
            end
        end
    end
    deactivate GitHub actions
    Reviewer->>issue: Adds a review comment
    activate Authenticated bot
    alt is PR AND commenter is not author of PR AND review-requested label exists
        Authenticated bot-->>Reviewer: Checks membership
        alt Reviewer is part of staged-recipes
            Authenticated bot->>issue: Remove review-requested label
            Authenticated bot->>issue: Add Awaiting author contribution label
        end
    end
    deactivate Authenticated bot
```

_Note_: The blue part is proposed and not actually integrated yet.

## Label State Diagram

```mermaid
stateDiagram-v2
    [*] --> reviewrequested,team: User pings team
    reviewrequested,team --> awaitingauthor,team: staged-recipes reviews
    awaitingauthor,team --> reviewrequested,team: User pings team
```
