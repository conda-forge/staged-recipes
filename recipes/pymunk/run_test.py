import pymunk

s = pymunk.Space()
b1 = pymunk.Body(10,10)
c1 = pymunk.Segment(b1, (-1,-1), (1,1), 1)
b2 = pymunk.Body(10,10)
c2 = pymunk.Segment(b2, (1,-1), (-1,1), 1)

s.add(b1,b2,c1,c2)

num_of_begins = 0
def begin(arb, space, data):
    global num_of_begins
    num_of_begins += 1
    print("begin")
    return True
    
s.add_default_collision_handler().begin=begin
for x in range(10):
  print(x)
  s.step(.1)