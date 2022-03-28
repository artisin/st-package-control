
ifeq ($(TAG),)
	TAG_PRV:=$(shell git describe --tags --abbrev=0)
	TAG:=$(shell git describe --tags --abbrev=0 | awk -F .   '{OFS="."; $$NF+=1; print}')
endif

# This function tests whether both arguments are equals
equals = $(and $(findstring $1,$2),$(findstring $2,$1))

push_and_tag:
	$(if $(call equals,0,$(shell git diff-index --quiet HEAD; echo $$?)),, \
		$(error There are uncomitted changes after running make $?) \
	)
	#	bump version for new tag
	sed -i -e "s/version\": \"${TAG_PRV}\"/version\": \"${TAG}\"/g" repository.json
	sed -i -e "s/\/${TAG_PRV}\//\/${TAG}\//g" repository.json
	# add/commit bump
	git add .
	git commit -m "bump(repository.json): ${TAG_PRV} → ${TAG}"
	# push update
	git push
	# tag and push
	git tag $(TAG)
	git push --tags
