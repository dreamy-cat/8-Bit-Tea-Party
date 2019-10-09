import random

print ('Game Hack The Old Terminal!')
random.seed()
wordSize = 3; variants = 9; word = ''; words = list()
if wordSize <= 1 or variants <= 1 or variants % wordSize > 0 :
	print('Wrong parameters of word size or variants.')
	quit()
i = 0; asciiA = 97; asciiZ = 122
while i < wordSize :
	word += chr(random.randint(asciiA, asciiZ))
	# print('%s' % word, end=' ')
	i += 1
print('Password to find \'%s\', variants %d.' % (word, variants))
print('Variant:\tLikeness:\tWord:')
while len(words) <= variants :
	variant = list(); i = 0; likeness = len(words) // (variants // wordSize)
	while i < wordSize : 
		if i < likeness :
			variant += word[i]
		else :
			c = chr(random.randint(asciiA, asciiZ))
			while c == word[i] :
				c = chr(random.randint(asciiA, asciiZ))
			variant += c
		i += 1
	i = 0
	while len(words) != variants and i < wordSize :
		idx1 = random.randint(0, wordSize - 1); idx2 = random.randint(0, wordSize - 1)
		c1 = variant[idx1]; c2 = variant[idx2]
		if c1 == word[idx1] :
			variant[idx2] = word[idx2]
		else:
			c = chr(random.randint(asciiA, asciiZ))
			while c == word[idx2] :
				c = chr(random.randint(asciiA, asciiZ))
			variant[idx2] = c
		if c2 == word[idx2] :
			variant[idx1] = word[idx1]
		else :
			c = chr(random.randint(asciiA, asciiZ))
			while c == word[idx1] :
				c = chr(random.randint(asciiA, asciiZ))
			variant[idx1] = c
		i += 1
	if variant not in words : 
		words.append(''.join(variant))
		print('%d\t\t\t%d\t\t\t%s' % (len(words), likeness, words[-1]))
	else :
		print('Variant \'%s\' is already in list of words.' % variant)
i = 0
while i < variants :
	idx1 = random.randint(0, len(words) - 1); idx2 = random.randint(0, len(words) - 1)
	variant = words[idx1]
	words[idx1] = words[idx2]
	words[idx2] = variant
	i += 1
print('Resort all words: ', end= ' ')
for c in words : print(c, end= ' ')
print('\nTrying to find password.')
print('Try and guess:\tWord:\tLikeness:\tPrevious:\tComment:')
attempts = dict(); attempt = ''; likeness = 0; i = 0; k = 0
while likeness < wordSize and i < len(words) :
	attempt = words[i]; likeness = 0; j = 0
	while j < len(attempt) :
		if attempt[j] == word[j] :
			likeness += 1;
		j += 1
	attempts[attempt] = likeness
	print('%d\t:\t%d\t\t%s\t\t%d\t\t\t-\t\t' % (k, 0, attempt, likeness), end = '\t')
	if likeness < wordSize : 
		print('Password not correct, trying to guess next variant.')
		j = i + 1; satisfy = 0
		while satisfy != len(attempts) and j < len(words) : 
			attempt = words[j]; satisfy = 0
			for previous in attempts :
				prevLikeness = 0; ix = 0
				while ix < len(attempt) :
					if attempt[ix] == previous[ix] : 
						prevLikeness += 1
					ix += 1
				print('%d\t:\t%d\t' % (k, j - i), end = '\t')
				print('%s\t\t%d\t\t\t%s\t\t' % (attempt, prevLikeness, previous), end = '\t')
				if attempts[previous] == prevLikeness : 
					satisfy += 1;
					print('Guess likeness is good as previous attempt.')
				else :
					print('Guess likeness not satisfy previous attempt.')
			ix = 0
			while ix < 4 : 
				print('\t\t', end = '\t')
				ix += 1
			if (satisfy == len(attempts)) : 
				print('The guess satisfies all previous attempts.')
			else :
				print('The guess not satisfies all previous attempts.')
				j += 1
		if satisfy != len(attempts) :
			print('Something goes wrong, next word not found.')
	else :
		print('Password founded! The Terminal Hacked!')
	i = j; k += 1
