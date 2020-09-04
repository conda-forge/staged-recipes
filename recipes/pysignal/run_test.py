from __future__ import print_function
import PySignal
from functools import partial

try:
    import unittest2 as unittest
except ImportError:
    import unittest


def testFunc(test, value):
    """A test standalone function for signals to attach onto"""
    test.checkval = value
    test.func_call_count += 1


def testLocalEmit(signal_instance):
    """A test standalone function for signals to emit at local level"""
    exec('signal_instance.emit()')


def testModuleEmit(signal_instance):
    """A test standalone function for signals to emit at module level"""
    signal_instance.emit()


class DummySignalClass(object):
    """A dummy class to check for instance handling of signals"""
    cSignal = PySignal.ClassSignal()
    cSignalFactory = PySignal.ClassSignalFactory()

    def __init__(self):
        self.signal = PySignal.Signal()
        self.signalFactory = PySignal.SignalFactory()

    def triggerSignal(self):
        self.signal.emit()

    def triggerClassSignal(self):
        self.cSignal.emit()


class DummySlotClass(object):
    """A dummy class to check for slot handling"""
    checkval = None

    def setVal(self, val):
        """A method to test slot calls with"""
        self.checkval = val


class SignalTestMixin(object):
    """Mixin class with common helpers for signal tests"""

    def __init__(self):
        self.checkval = None  # A state check for the tests
        self.checkval2 = None  # A state check for the tests
        self.setVal_call_count = 0  # A state check for the test method
        self.setVal2_call_count = 0  # A state check for the test method
        self.func_call_count = 0  # A state check for test function

    def reset(self):
        self.checkval = None
        self.checkval2 = None
        self.setVal_call_count = 0
        self.setVal2_call_count = 0
        self.func_call_count = 0

    # Helper methods
    def setVal(self, val):
        """A method to test instance settings with"""
        self.checkval = val
        self.setVal_call_count += 1

    def setVal2(self, val):
        """Another method to test instance settings with"""
        self.checkval2 = val
        self.setVal2_call_count += 1

    def throwaway(self, *args):
        """A method to throw redundant data into"""
        pass


# noinspection PyProtectedMember
class SignalTest(unittest.TestCase, SignalTestMixin):
    """Unit tests for Signal class"""

    def setUp(self):
        self.reset()

    def __init__(self, methodName='runTest'):
        unittest.TestCase.__init__(self, methodName)
        SignalTestMixin.__init__(self)

    def test_PartialConnect(self):
        """Tests connecting signals to partials"""
        partialSignal = PySignal.Signal()
        partialSignal.connect(partial(testFunc, self, 'Partial'))
        self.assertEqual(len(partialSignal._slots), 1, "Expected single connected slot")

    def test_PartialConnectDuplicate(self):
        """Tests connecting signals to partials"""
        partialSignal = PySignal.Signal()
        func = partial(testFunc, self, 'Partial')
        partialSignal.connect(func)
        partialSignal.connect(func)
        self.assertEqual(len(partialSignal._slots), 1, "Expected single connected slot")

    def test_LambdaConnect(self):
        """Tests connecting signals to lambdas"""
        lambdaSignal = PySignal.Signal()
        lambdaSignal.connect(lambda value: testFunc(self, value))
        self.assertEqual(len(lambdaSignal._slots), 1, "Expected single connected slot")

    def test_LambdaConnectDuplicate(self):
        """Tests connecting signals to duplicate lambdas"""
        lambdaSignal = PySignal.Signal()
        func = lambda value: testFunc(self, value)
        lambdaSignal.connect(func)
        lambdaSignal.connect(func)
        self.assertEqual(len(lambdaSignal._slots), 1, "Expected single connected slot")

    def test_MethodConnect(self):
        """Test connecting signals to methods on class instances"""
        methodSignal = PySignal.Signal()
        methodSignal.connect(self.setVal)
        self.assertEqual(len(methodSignal._slots), 1, "Expected single connected slot")

    def test_MethodConnectDuplicate(self):
        """Test that each method connection is unique"""
        methodSignal = PySignal.Signal()
        methodSignal.connect(self.setVal)
        methodSignal.connect(self.setVal)
        self.assertEqual(len(methodSignal._slots), 1, "Expected single connected slot")

    def test_MethodConnectDifferentInstances(self):
        """Test connecting the same method from different instances"""
        methodSignal = PySignal.Signal()
        dummy1 = DummySlotClass()
        dummy2 = DummySlotClass()
        methodSignal.connect(dummy1.setVal)
        methodSignal.connect(dummy2.setVal)
        self.assertEqual(len(methodSignal._slots), 2, "Expected two connected slots")

    def test_FunctionConnect(self):
        """Test connecting signals to standalone functions"""
        funcSignal = PySignal.Signal()
        funcSignal.connect(testFunc)
        self.assertEqual(len(funcSignal._slots), 1, "Expected single connected slot")

    def test_FunctionConnectDuplicate(self):
        """Test that each function connection is unique"""
        funcSignal = PySignal.Signal()
        funcSignal.connect(testFunc)
        funcSignal.connect(testFunc)
        self.assertEqual(len(funcSignal._slots), 1, "Expected single connected slot")

    def test_ConnectNonCallable(self):
        """Test connecting non-callable object"""
        nonCallableSignal = PySignal.Signal()
        with self.assertRaises(ValueError):
            nonCallableSignal.connect(self.checkval)

    def test_EmitToPartial(self):
        """Test emitting signals to partial"""
        partialSignal = PySignal.Signal()
        partialSignal.connect(partial(testFunc, self, 'Partial'))
        partialSignal.emit()
        self.assertEqual(self.checkval, 'Partial')
        self.assertEqual(self.func_call_count, 1, "Expected function to be called once")

    def test_EmitToLambda(self):
        """Test emitting signal to lambda"""
        lambdaSignal = PySignal.Signal()
        lambdaSignal.connect(lambda value: testFunc(self, value))
        lambdaSignal.emit('Lambda')
        self.assertEqual(self.checkval, 'Lambda')
        self.assertEqual(self.func_call_count, 1, "Expected function to be called once")

    def test_EmitToMethod(self):
        """Test emitting signal to method"""
        toSucceed = DummySignalClass()
        toSucceed.signal.connect(self.setVal)
        toSucceed.signal.emit('Method')
        self.assertEqual(self.checkval, 'Method')
        self.assertEqual(self.setVal_call_count, 1, "Expected function to be called once")

    def test_EmitToMethodOnDeletedInstance(self):
        """Test emitting signal to deleted instance method"""
        toDelete = DummySlotClass()
        toCall = PySignal.Signal()
        toCall.connect(toDelete.setVal)
        toCall.connect(self.setVal)
        del toDelete
        toCall.emit(1)
        self.assertEqual(self.checkval, 1)

    def test_EmitToFunction(self):
        """Test emitting signal to standalone function"""
        funcSignal = PySignal.Signal()
        funcSignal.connect(testFunc)
        funcSignal.emit(self, 'Function')
        self.assertEqual(self.checkval, 'Function')
        self.assertEqual(self.func_call_count, 1, "Expected function to be called once")

    def test_EmitToDeletedFunction(self):
        """Test emitting signal to deleted instance method"""
        def ToDelete(test, value):
            test.checkVal = value
            test.func_call_count += 1
        funcSignal = PySignal.Signal()
        funcSignal.connect(ToDelete)
        del ToDelete
        funcSignal.emit(self, 1)
        self.assertEqual(self.checkval, None)
        self.assertEqual(self.func_call_count, 0)

    def test_PartialDisconnect(self):
        """Test disconnecting partial function"""
        partialSignal = PySignal.Signal()
        part = partial(testFunc, self, 'Partial')
        partialSignal.connect(part)
        partialSignal.disconnect(part)
        self.assertEqual(self.checkval, None, "Slot was not removed from signal")

    def test_PartialDisconnectUnconnected(self):
        """Test disconnecting unconnected partial function"""
        partialSignal = PySignal.Signal()
        part = partial(testFunc, self, 'Partial')
        try:
            partialSignal.disconnect(part)
        except:
            self.fail("Disonnecting unconnected partial should not raise")

    def test_LambdaDisconnect(self):
        """Test disconnecting lambda function"""
        lambdaSignal = PySignal.Signal()
        func = lambda value: testFunc(self, value)
        lambdaSignal.connect(func)
        lambdaSignal.disconnect(func)
        self.assertEqual(len(lambdaSignal._slots), 0, "Slot was not removed from signal")

    def test_LambdaDisconnectUnconnected(self):
        """Test disconnecting unconnected lambda function"""
        lambdaSignal = PySignal.Signal()
        func = lambda value: testFunc(self, value)
        try:
            lambdaSignal.disconnect(func)
        except:
            self.fail("Disconnecting unconnected lambda should not raise")

    def test_MethodDisconnect(self):
        """Test disconnecting method"""
        toCall = PySignal.Signal()
        toCall.connect(self.setVal)
        toCall.connect(self.setVal2)
        toCall.disconnect(self.setVal2)
        toCall.emit(1)
        self.assertEqual(len(toCall._slots), 1, "Expected 1 connected after disconnect, found %d" % len(toCall._slots))
        self.assertEqual(self.setVal_call_count, 1, "Expected function to be called once")
        self.assertEqual(self.setVal2_call_count, 0, "Expected function to not be called after disconnecting")

    def test_MethodDisconnectUnconnected(self):
        """Test disconnecting unconnected method"""
        toCall = PySignal.Signal()
        try:
            toCall.disconnect(self.setVal)
        except:
            self.fail("Disconnecting unconnected method should not raise")

    def test_FunctionDisconnect(self):
        """Test disconnecting function"""
        funcSignal = PySignal.Signal()
        funcSignal.connect(testFunc)
        funcSignal.disconnect(testFunc)
        self.assertEqual(len(funcSignal._slots), 0, "Slot was not removed from signal")

    def test_FunctionDisconnectUnconnected(self):
        """Test disconnecting unconnected function"""
        funcSignal = PySignal.Signal()
        try:
            funcSignal.disconnect(testFunc)
        except:
            self.fail("Disconnecting unconnected function should not raise")

    def test_DisconnectNonCallable(self):
        """Test disconnecting non-callable object"""
        signal = PySignal.Signal()
        try:
            signal.disconnect(self.checkval)
        except:
            self.fail("Disconnecting invalid object should not raise")

    def test_ClearSlots(self):
        """Test clearing all slots"""
        multiSignal = PySignal.Signal()
        func = lambda value: self.setVal(value)
        multiSignal.connect(func)
        multiSignal.connect(self.setVal)
        multiSignal.clear()
        self.assertEqual(len(multiSignal._slots), 0, "Not all slots were removed from signal")


class ClassSignalTest(unittest.TestCase, SignalTestMixin):
    """Unit tests for ClassSignal class"""

    def setUp(self):
        self.reset()

    def __init__(self, methodName='runTest'):
        unittest.TestCase.__init__(self, methodName)
        SignalTestMixin.__init__(self)

    def test_AssignToProperty(self):
        """Test assigning to a ClassSignal property"""
        dummy = DummySignalClass()
        with self.assertRaises(RuntimeError):
            dummy.cSignal = None

    # noinspection PyUnresolvedReferences
    def test_Emit(self):
        """Test emitting signals from class signal and that instances of the class are unique"""
        toSucceed = DummySignalClass()
        toSucceed.cSignal.connect(self.setVal)
        toFail = DummySignalClass()
        toFail.cSignal.connect(self.throwaway)
        toSucceed.cSignal.emit(1)
        toFail.cSignal.emit(2)
        self.assertEqual(self.checkval, 1)

    def test_DeadSenderFound(self):
        """Test Signal sender is dead"""
        toFail = DummySignalClass()
        toFail.cSignal.connect(self.throwaway)
        toFail.triggerClassSignal()
        weak_sender = toFail.cSignal._sender
        del toFail
        self.assertEqual(None, weak_sender())

    def test_FunctionSenderFound(self):
        """Test correct Signal sender is found (instance method)"""
        toSucceed = DummySignalClass()
        toSucceed.cSignal.connect(self.throwaway)
        toSucceed.triggerClassSignal()
        self.assertEqual(toSucceed.triggerClassSignal, toSucceed.cSignal.sender())

    def test_InstanceSenderFound(self):
        """Test correct Signal sender is found (instance, not class method)"""
        toSucceed = DummySignalClass()
        toSucceed.cSignal.connect(self.throwaway)
        toSucceed.triggerClassSignal()
        self.assertNotEqual(DummySignalClass.triggerClassSignal, toSucceed.cSignal.sender())
        self.assertEqual(toSucceed.triggerClassSignal, toSucceed.cSignal.sender())

    def test_LambdaSenderFound(self):
        """Test correct Signal sender is found (instance method via lambda)"""
        toSucceed = DummySignalClass()
        toSucceed.cSignal.connect(self.throwaway)
        (lambda: toSucceed.triggerClassSignal())()
        self.assertEqual(toSucceed.triggerClassSignal, toSucceed.cSignal.sender())

    def test_PartialSenderFound(self):
        """Test correct Signal sender is found (instance method via partial)"""
        toSucceed = DummySignalClass()
        toSucceed.cSignal.connect(self.throwaway)
        partial(toSucceed.triggerClassSignal)()
        self.assertEqual(toSucceed.triggerClassSignal, toSucceed.cSignal.sender())

    def test_SelfSenderFound(self):
        """Test correct Signal sender is found (self emit)"""
        toSucceed = DummySignalClass()
        toSucceed.cSignal.connect(self.throwaway)
        toSucceed.cSignal.emit()
        self.assertEqual(self.test_SelfSenderFound, toSucceed.cSignal.sender())

    def test_LocalSenderHandled(self):
        """Test correct Signal sender is found (module local emit)"""
        toFail = DummySignalClass()
        toFail.cSignal.connect(self.throwaway)
        testLocalEmit(toFail.cSignal)
        self.assertEqual(None, toFail.cSignal.sender())

    def test_ModuleSenderHandled(self):
        """Test correct Signal sender is found (module local emit)"""
        toFail = DummySignalClass()
        toFail.cSignal.connect(self.throwaway)
        testModuleEmit(toFail.cSignal)
        self.assertEqual(None, toFail.cSignal.sender())


class SignalFactoryTest(unittest.TestCase, SignalTestMixin):
    def __init__(self, methodName='runTest'):
        unittest.TestCase.__init__(self, methodName)
        SignalTestMixin.__init__(self)

    def setUp(self):
        self.reset()

    # noinspection PyUnresolvedReferences
    def test_Emit(self):
        """Test emitting signals from class signal factory and that class instances are unique"""
        toSucceed = DummySignalClass()
        toSucceed.cSignalFactory.register('Spam')
        toSucceed.cSignalFactory['Spam'].connect(self.setVal)
        toFail = DummySignalClass()
        toFail.cSignalFactory.register('Spam')
        toFail.cSignalFactory['Spam'].connect(self.throwaway)
        toSucceed.cSignalFactory['Spam'].emit(1)
        toFail.cSignalFactory['Spam'].emit(2)
        self.assertEqual(self.checkval, 1)


class ClassSignalFactoryTest(unittest.TestCase, SignalTestMixin):
    def __init__(self, methodName='runTest'):
        unittest.TestCase.__init__(self, methodName)
        SignalTestMixin.__init__(self)

    def setUp(self):
        self.checkval = None
        self.checkval2 = None
        self.setVal_call_count = 0
        self.setVal2_call_count = 0
        self.func_call_count = 0

    def test_AssignToProperty(self):
        """Test assigning to a ClassSignalFactory property"""
        dummy = DummySignalClass()
        with self.assertRaises(RuntimeError):
            dummy.cSignalFactory = None

    def test_Connect(self):
        """Test SignalFactory indirect signal connection"""
        dummy = DummySignalClass()
        dummy.signalFactory.register('Spam')
        dummy.signalFactory.connect('Spam', self.setVal)
        dummy.signalFactory.emit('Spam', 1)
        self.assertEqual(self.checkval, 1)
        self.assertEqual(self.setVal_call_count, 1)

    def test_ConnectInvalidChannel(self):
        """Test SignalFactory connecting to invalid channel"""
        dummy = DummySignalClass()
        with self.assertRaises(AssertionError):
            dummy.signalFactory.connect('Spam', self.setVal)

    def test_Emit(self):
        """Test emitting signals from signal factory"""
        toSucceed = DummySignalClass()
        toSucceed.signalFactory.register('Spam')
        toSucceed.signalFactory['Spam'].connect(self.setVal)
        toSucceed.signalFactory['Spam'].emit(1)
        self.assertEqual(self.checkval, 1)

    def test_BlockSingle(self):
        """Test blocking single channel with signal factory"""
        dummy = DummySignalClass()
        dummy.signalFactory.register('Spam', self.setVal)
        dummy.signalFactory.register('Eggs', self.setVal2)
        dummy.signalFactory.block('Spam')
        dummy.signalFactory.emit('Spam', 1)
        dummy.signalFactory.emit('Eggs', 2)
        self.assertEqual(self.checkval, None)
        self.assertEqual(self.checkval2, 2)

    def test_UnblockSingle(self):
        """Test unblocking a single channel with signal factory"""
        dummy = DummySignalClass()
        dummy.signalFactory.register('Spam', self.setVal)
        dummy.signalFactory.register('Eggs', self.setVal2)
        dummy.signalFactory.block('Spam')
        dummy.signalFactory.block('Spam', False)
        dummy.signalFactory.emit('Spam', 1)
        dummy.signalFactory.emit('Eggs', 2)
        self.assertEqual(self.checkval, 1)
        self.assertEqual(self.checkval2, 2)

    def test_BlockAll(self):
        """Test blocking all signals from signal factory"""
        dummy = DummySignalClass()
        dummy.signalFactory.register('Spam', self.setVal)
        dummy.signalFactory.register('Eggs', self.setVal2)
        dummy.signalFactory.block()
        dummy.signalFactory.emit('Spam', 1)
        dummy.signalFactory.emit('Eggs', 2)
        self.assertEqual(self.checkval, None)
        self.assertEqual(self.checkval2, None)

    def test_UnblockAll(self):
        """Test unblocking all signals from signal factory"""
        dummy = DummySignalClass()
        dummy.signalFactory.register('Spam', self.setVal)
        dummy.signalFactory.register('Eggs', self.setVal2)
        dummy.signalFactory.block()
        dummy.signalFactory.block(isBlocked=False)
        dummy.signalFactory.emit('Spam', 1)
        dummy.signalFactory.emit('Eggs', 2)
        self.assertEqual(self.checkval, 1)
        self.assertEqual(self.checkval2, 2)

    def test_BlockInvalidChannel(self):
        """Test blocking an invalid channel from signal factory"""
        dummy = DummySignalClass()
        with self.assertRaises(RuntimeError):
            dummy.signalFactory.block('Spam')

    def test_Deregister(self):
        """Test unregistering from SignalFactory"""
        dummy = DummySignalClass()
        dummy.signalFactory.register('Spam')
        dummy.signalFactory.deregister('Spam')
        self.assertFalse('Spam' in dummy.signalFactory, "Signal not removed")

    def test_DeregisterInvalidChannel(self):
        """Test unregistering invalid channel from SignalFactory"""
        dummy = DummySignalClass()
        try:
            dummy.signalFactory.deregister('Spam')
        except KeyError:
            self.fail("Deregistering invalid channel should not raise KeyError")


if __name__ == '__main__':
    unittest.main()
