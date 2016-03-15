#!/bin/bash

REPOUR_REPO=/tmp/repour-test-repos/undertow


UPSTREAM_REPO_URL=https://github.com/undertow-io/undertow.git
INTERNAL_REPO_URL=git://git.app.eng.bos.redhat.com/undertow-io/undertow.git

INTERNAL_REPO=/tmp/undertow


create_internal_repo() {	
	echo "Cloning internal and upstream repo"
	rm -rf $INTERNAL_REPO
	mkdir $INTERNAL_REPO
	cd $INTERNAL_REPO
	git init
	git remote add upstream $UPSTREAM_REPO_URL
	git remote add prod $INTERNAL_REPO_URL
	git fetch --all --tags
}


show_repo_info() {
	local REPO=$1
	echo "Show content of repo $REPO"
	du -s $REPO
	cd $REPO
	echo "Branches"
	git branch -a
	echo "Tags"
	git -C tag -ln9
}

add_tag_to_repour_repo() {
	local REPO_URL=$1
	local TAG=$2
	echo "Processing $TAG"
	echo curl -s -S -H "Content-Type: application/json" -X POST -d '{ "name": "undertow", "type": "git", "ref": "'$TAG'", "url": "'$REPO_URL'" }' http://localhost:7331/pull
	curl -s -S -H "Content-Type: application/json" -X POST -d '{ "name": "undertow", "type": "git", "ref": "'$TAG'", "url": "'$REPO_URL'" }' http://localhost:7331/pull
	du -s $REPOUR_REPO	
}

create_repour_internal_repo() {
	rm -rf $REPOUR_REPO
#	declare -a TAGS=("1.0.0.Final" "1.0.1.Final" "1.0.10.Final" "1.0.11.Final" "1.0.12.Final" "1.0.13.Final" "1.0.14.Final" "1.0.15.Final" "1.0.16.Final" "1.0.17.Final" "1.0.18.Final" "1.0.19.Final" "1.0.2.Final" "1.0.3.Final" "1.0.4.Final" "1.0.5.Final" "1.0.6.Final" "1.0.7.Final" "1.0.8.Final" "1.0.9.Final" "1.1.0.Final" "1.1.1.Final" "1.1.2.Final" "1.1.3.Final" "1.1.4.Final" "1.1.5.Final" "1.1.6.Final" "1.1.7.Final" "1.1.8.Final" "1.1.9.Final" "1.2.0.Final" "1.2.1.Final" "1.2.10.Final" "1.2.11.Final" "1.2.12.Final" "1.2.2.Final" "1.2.3.Final" "1.2.4.Final" "1.2.5.Final" "1.2.6.Final" "1.2.7.Final" "1.2.8.Final" "1.2.9.Final" "1.3.0.Final" "1.3.1.Final" "1.3.2.Final" "1.3.3.Final" "1.3.4.Final" "1.3.5.Final" "1.3.6.Final" "1.3.7.Final" "1.3.8.Final" "1.3.9.Final" "1.3.10.Final" "1.3.11.Final" "1.3.12.Final" "1.3.13.Final" "1.3.14.Final" "1.3.15.Final" "1.3.16.Final" "1.3.17.Final" "1.3.18.Final")
	declare -a TAGS=("1.3.18.Final")
	for TAG in "${TAGS[@]}"
	do
		add_tag_to_repour_repo $UPSTREAM_REPO_URL $TAG
	done
}


add_tag_to_repour_repo() {
	local REPO_URL=$1
	local TAG=$2
	echo "Processing $TAG"
	echo curl -s -S -H "Content-Type: application/json" -X POST -d '{ "name": "undertow", "type": "git", "ref": "'$TAG'", "url": "'$REPO_URL'" }' http://localhost:7331/pull; echo ""
	curl -s -S -H "Content-Type: application/json" -X POST -d '{ "name": "undertow", "type": "git", "ref": "'$TAG'", "url": "'$REPO_URL'" }' http://localhost:7331/pull; echo ""
	du -s $REPOUR_REPO	
}


apply_prod_change_to_repour_repo() {
	local REPO_URL=$1
	local TAG=$2
	echo "Processing $TAG"
	echo -s -S -H "Content-Type: application/json" -X POST -d '{ "name": "undertow", "type": "git", "ref": "'$TAG'", "url": "'$REPO_URL'", "adjust": true}' http://localhost:7331/pull ; echo ""
	curl -s -S -H "Content-Type: application/json" -X POST -d '{ "name": "undertow", "type": "git", "ref": "'$TAG'", "url": "'$REPO_URL'", "adjust": true}' http://localhost:7331/pull ; echo ""
	du -s $REPOUR_REPO	
}

apply_prod_changes() {
#	declare -a REDHAT_TAGS=("1.3.14.Final-redhat-1" "1.3.16.Final-redhat-1" "1.3.17.Final-redhat-1" "1.3.18.Final-redhat-1")
	declare -a REDHAT_TAGS=("1.3.18.Final")
	for REDHAT_TAG in "${REDHAT_TAGS[@]}"
	do
		apply_prod_change_to_repour_repo $INTERNAL_REPO_URL $REDHAT_TAG
	done
}

apply_prod_changes_orig() {
	declare -a REDHAT_TAGS=("1.3.14.Final-redhat-1" "1.3.16.Final-redhat-1" "1.3.17.Final-redhat-1" "1.3.18.Final-redhat-1")
	for REDHAT_TAG in "${REDHAT_TAGS[@]}"
	do
		add_tag_to_repour_repo $INTERNAL_REPO_URL $REDHAT_TAG
	done
}

#create_internal_repo
#show_repo_info $INTERNAL_REPO
create_repour_internal_repo
apply_prod_changes
show_repo_info $REPOUR_REPO

#request
#curl -H "Content-Type: application/json" -X POST -d '{ "name": "undertow", "type": "git", "ref": "1.3.7.Final", "url": "https://github.com/undertow-io/undertow.git" }' http://localhost:7331/pull
#curl -H "Content-Type: application/json" -X POST -d '{ "name": "undertow", "type": "git", "ref": "1.3.8.Final", "url": "https://github.com/undertow-io/undertow.git" }' http://localhost:7331/pull


# response 
# {"branch": "branch-pull-3826f26c4b7a137f381c073acd4c6c3d17fe197c", "tag": "repour-3826f26c4b7a137f381c073acd4c6c3d17fe197c", "url": {"readwrite": "file:///tmp/repour-test-repos/teiid", "readonly": "file:///tmp/repour-test-repos/teiid"}}


#"1.0.0.Alpha1" "1.0.0.Alpha10" "1.0.0.Alpha11" "1.0.0.Alpha12" "1.0.0.Alpha13" "1.0.0.Alpha14" "1.0.0.Alpha15" "1.0.0.Alpha16" "1.0.0.Alpha17" "1.0.0.Alpha18" "1.0.0.Alpha19" "1.0.0.Alpha2" "1.0.0.Alpha20" "1.0.0.Alpha21" "1.0.0.Alpha22" "1.0.0.Alpha3" "1.0.0.Alpha4" "1.0.0.Alpha5" "1.0.0.Alpha6" "1.0.0.Alpha7" "1.0.0.Alpha8" "1.0.0.Alpha9" "1.0.0.Beta1" "1.0.0.Beta10" "1.0.0.Beta11" "1.0.0.Beta12" "1.0.0.Beta13" "1.0.0.Beta14" "1.0.0.Beta15" "1.0.0.Beta16" "1.0.0.Beta17" "1.0.0.Beta18" "1.0.0.Beta19" "1.0.0.Beta2" "1.0.0.Beta20" "1.0.0.Beta21" "1.0.0.Beta22" "1.0.0.Beta23" "1.0.0.Beta24" "1.0.0.Beta25" "1.0.0.Beta26" "1.0.0.Beta27" "1.0.0.Beta28" "1.0.0.Beta29" "1.0.0.Beta3" "1.0.0.Beta30" "1.0.0.Beta31" "1.0.0.Beta32" "1.0.0.Beta33" "1.0.0.Beta4" "1.0.0.Beta5" "1.0.0.Beta6" "1.0.0.Beta7" "1.0.0.Beta8" "1.0.0.Beta9" "1.0.0.CR1" "1.0.0.CR2" "1.0.0.CR3" "1.0.0.CR4" "1.0.0.CR5" "1.1.0.Beta1" "1.1.0.Beta2" "1.1.0.Beta3" "1.1.0.Beta4" "1.1.0.Beta5" "1.1.0.Beta6" "1.1.0.Beta7" "1.1.0.Beta8" "1.1.0.CR1" "1.1.0.CR2" "1.1.0.CR3" "1.1.0.CR4" "1.1.0.CR5" "1.1.0.CR6" "1.1.0.CR7" "1.1.0.CR8" "1.2.0.Beta1" "1.2.0.Beta10" "1.2.0.Beta2" "1.2.0.Beta3" "1.2.0.Beta4" "1.2.0.Beta5" "1.2.0.Beta6" "1.2.0.Beta7" "1.2.0.Beta8" "1.2.0.Beta9" "1.2.0.CR1" "1.3.0.Beta1" "1.3.0.Beta10" "1.3.0.Beta11" "1.3.0.Beta12" "1.3.0.Beta13" "1.3.0.Beta2" "1.3.0.Beta3" "1.3.0.Beta4" "1.3.0.Beta5" "1.3.0.Beta6" "1.3.0.Beta7" "1.3.0.Beta8" "1.3.0.Beta9" "1.3.0.CR1" "1.3.0.CR2" "1.3.0.CR3"
