package hu.elte.sm.validation

import com.google.inject.Inject
import hu.elte.sm.sM.SMMachine
import hu.elte.sm.sM.SMRaiseEventExpression
import hu.elte.sm.sM.SMState
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations

import static hu.elte.sm.sM.SMPackage.Literals.*
import static hu.elte.sm.validation.SMIssueCodes.*

/**
 * The validator can be used to define static validation rules for our language.
 * The AST traversal is done automatically by the framework, where one-parameter
 * methods annotated with '@Check' are called for each matching node.
 * 
 * See: https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#custom-validation
 */
class SMValidator extends AbstractSMValidator {

	@Inject extension IJvmModelAssociations

	@Check
	def checkInitStateIsDefined(SMMachine it) {
		if (!members.filter(SMState).exists[init]) {
			error("Missing initial state in machine " + name, SM_MACHINE__NAME, MISSING_INITIAL_STATE)
		}
	}

	@Check
	def checkRaisedEventIsSpecified(SMRaiseEventExpression it) {
		if (event === null) {
			error("Missing event in raise expression", null, MISSING_EVENT_IN_RAISE)
		}
	}

	@Check
	def checkRaisedEventIsOwned(SMRaiseEventExpression it) {
		if (event !== null && target !== null) {
			val targetMachine = target.actualType.type.primarySourceElement as SMMachine
			if (event.eContainer != targetMachine) {
				error('''Event �event.name� does not belong to machine �targetMachine.name�''',
					SM_RAISE_EVENT_EXPRESSION__EVENT, NOT_OWNED_EVENT_IN_RAISE)
			}
		}
	}

	/**
	 * Remember that in Xbase, even statements can be used as expressions. However,
	 * similarly to dead code, pure expressions (i.e. no side effects) are not allowed
	 * as a separate statement inside a block. Here we specify that 'RaiseEvent' is OK
	 * to stand on his own.
	 */
	override isValueExpectedRecursive(XExpression expression) {
		expression instanceof SMRaiseEventExpression || super.isValueExpectedRecursive(expression)
	}

}
